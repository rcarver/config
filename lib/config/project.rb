module Config
  class Project

    UnknownCluster = Class.new(StandardError)
    UnknownBlueprint = Class.new(StandardError)

    class PathHash < Hash
      def initialize(dir)
        @dir = dir
        super()
      end
      def [](key)
        if key.include?("/")
          if (@dir + key).exist?
            super File.basename(key, ".rb")
          else
            raise ArgumentError, "File does not exist #{key.inspect}"
          end
        else
          super
        end
      end
    end

    def initialize(dir)
      @dir = Pathname.new(dir).cleanpath
      @clusters = PathHash.new(@dir)
      @blueprints = PathHash.new(@dir)
    end

    attr :clusters
    attr :blueprints

    # Get the project Hub. The Hub describes centralized aspects of your
    # system.
    #
    # Returns a Config::Hub.
    def hub
      @hub ||= begin
        file = @dir + "hub.rb"

        hub = file.exist? ? Config::Hub.from_file(@dir + "hub.rb") : Hub.new

        if !hub.git_project
          repo = `cd #{@dir} && git config --get remote.origin.url`
          hub.git_project = repo.empty? ? nil : repo.chomp
        end

        if hub.git_project && !hub.git_data
          hub.git_data = hub.git_project.sub(/\.git/, '-data.git')
        end

        hub
      end
    end

    # Get the data directory. The data directory stores information
    # about the state of your system.
    #
    # Returns a Config::Data::Dir.
    def data_dir
      @data_dir ||= begin
        (@dir + ".data").mkdir unless (@dir + ".data").exist?
        Config::Data::Dir.new(@dir + ".data")
      end
    end

    # Clone the data repo and store it in the data dir. Does nothing if
    # the data repo already exists.
    #
    # Returns nothing.
    def clone_data_repo
      data_dir.repo.clone(hub.git_data) unless data_dir.repo.cloned?
    end

    def try_blueprint(blueprint_name, cluster_name = nil)
      require_all

      blueprint = blueprints[blueprint_name]
      blueprint or raise UnknownBlueprint, "Blueprint #{blueprint_name} was not found"

      if cluster_name
        cluster = clusters[cluster_name]
        cluster or raise UnknownCluster, "Cluster #{cluster_name} was not found"
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

      Dir[(@dir + "patterns/**/*.rb")].each do |f|
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

      Dir[(@dir + "clusters/*.rb")].each do |f|
        cluster = Cluster.from_file(f)
        @clusters[cluster.name] = cluster
      end
    end

    def require_blueprints
      return if @required_blueprints; @required_blueprints = true

      Dir[(@dir + "blueprints/*.rb")].each do |f|
        blueprint = Blueprint.from_file(f)
        @blueprints[blueprint.name] = blueprint
      end
    end
  end
end
