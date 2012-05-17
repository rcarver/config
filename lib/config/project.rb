module Config
  class Project

    UnknownNode = Class.new(StandardError)
    UnknownCluster = Class.new(StandardError)
    UnknownBlueprint = Class.new(StandardError)

    class PathHash < Hash
      def initialize(path)
        @path = path
        super()
      end
      def [](key)
        if key.include?("/")
          if (@path + key).exist?
            super File.basename(key, ".rb")
          else
            raise ArgumentError, "File does not exist #{key.inspect}"
          end
        else
          super 
        end
      end
    end

    def initialize(project_path, data_path)
      @path = Pathname.new(project_path).cleanpath
      @data_path = Pathname.new(data_path).cleanpath
      @data_dir = Config::Data::Dir.new(@data_path)

      @clusters = PathHash.new(@path)
      @blueprints = PathHash.new(@path)
      @nodes = PathHash.new(@data_dir.repo_path)
    end

    # Get the data directory. The data directory stores information
    # about the state of your system.
    #
    # Returns a Config::Data::Dir.
    def data_dir
      @data_path.mkpath # TODO: don't mkpath
      @data_dir
    end

    # Get the database. The database stores information about your
    # nodes.
    #
    # Returns a Config::Data::Database.
    def database
      @database or data_dir.database
    end

    # Get the project Hub. The Hub describes centralized aspects of your
    # system.
    #
    # Returns a Config::Hub.
    def hub
      @hub ||= begin
        file = @path + "hub.rb"

        hub = file.exist? ? Config::Hub.from_file(@path + "hub.rb") : Hub.new

        hub.project_config ||= Config::Core::GitConfig.new
        hub.data_config    ||= Config::Core::GitConfig.new

        if !hub.project_config.url
          repo = `cd #{@path} && git config --get remote.origin.url`
          hub.project_config.url = repo.empty? ? nil : repo.chomp
        end

        if hub.project_config.url && !hub.data_config.url
          hub.data_config.url = hub.project_config.url.sub(/\.git/, '-data.git')
        end

        hub
      end
    end

    # Update the stored node data by inspecting the current execution
    # environment.
    #
    # fqn - String Node FQN.
    #
    # Returns a Config::Node.
    def update_node!(fqn)
      begin
        node = get_node(fqn)
      rescue UnknownNode
        node = Config::Node.from_fqn(fqn)
      end

      node.facts = fact_inventor.call
      database.update_node(node)

      node
    end

    # Remove the node from the database.
    #
    # fqn - String Node FQN.
    #
    # Returns nothing.
    def remove_node!(fqn)
      node = get_node(fqn)
      database.remove_node(node)
      nil
    end

    # Execute the node's blueprint.
    #
    # fqn - String Node FQN.
    #
    # Returns a Config::Node.
    def execute_node!(fqn)
      require_all

      node = get_node(fqn)
      cluster = get_cluster(node.cluster_name)
      blueprint = get_blueprint(node.blueprint_name)

      blueprint.configuration = cluster.configuration
      blueprint.accumulate
      blueprint.validate
      blueprint.execute

      node
    end

    # Execute a blueprint in noop mode.
    #
    # blueprint_name - String name of the blueprint.
    # cluster_name   - String name of the cluster (default: execute with
    #                  a Spy cluster)
    #
    # Returns nothing.
    def try_blueprint(blueprint_name, cluster_name = nil)
      require_all

      blueprint = get_blueprint(blueprint_name)

      if cluster_name
        cluster = get_cluster(cluster_name)
        blueprint.configuration = cluster.configuration
      else
        blueprint.configuration = Config::Spy::Configuration.new
      end

      accumulation = blueprint.accumulate
      accumulation.each do |pattern|
        pattern.noop!
      end

      blueprint.validate
      blueprint.execute
    end

    def require_all
      require_patterns
      require_clusters
      require_blueprints
    end

    def require_patterns
      return if @required_patterns; @required_patterns = true

      Dir[(@path + "patterns/**/*.rb")].each do |f|
        begin
          require f
        rescue NameError => e
          # This allows files to be written as `class Topic::Pattern`
          # instead of `module Topic; class Pattern` which makes the
          # file nicer because it reduces the indentation. However, we
          # need to perform this trick so that Ruby doesn't choke on the
          # undefined constant `Topic`. An alternative approach would be
          # to infer the module name from the file name. This would be
          # good because it enforces naming convensions but it also
          # feels less obvious.
          name = e.message[/^uninitialized constant\s([A-Z].*)$/, 1]
          if name
            Object.const_set(name, Module.new)
            retry
          else
            raise "Could not auto-define a constant in #{f}. The message was #{e.message.inspect}"
          end
        end
      end
    end

    def require_clusters
      return if @required_clusters; @required_clusters = true

      Dir[(@path + "clusters/*.rb")].each do |f|
        cluster = Cluster.from_file(f)
        @clusters[cluster.name] = cluster
      end
    end

    def require_blueprints
      return if @required_blueprints; @required_blueprints = true

      Dir[(@path + "blueprints/*.rb")].each do |f|
        blueprint = Blueprint.from_file(f)
        @blueprints[blueprint.name] = blueprint
      end
    end

    def get_cluster(name)
      @clusters[name] or raise UnknownCluster, "Cluster #{name.inspect} was not found"
    end

    def get_blueprint(name)
      @blueprints[name] or raise UnknownBlueprint, "Blueprint #{name.inspect} was not found"
    end

    def get_node(name)
      database.find_node(name) or raise UnknownNode, "Node #{name.inspect} was not found"
    end

    #
    # Internal / Dependency Injection
    #

    attr_writer :database

    attr_writer :fact_inventor

    def fact_inventor
      @fact_inventor || proc { Config::Core::Facts.invent }
    end

  end
end
