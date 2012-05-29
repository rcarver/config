module Config
  module Core
    class ProjectLoader

      def initialize(path)
        @path = Pathname.new(path).cleanpath

        @clusters = PathHash.new(@path)
        @blueprints = PathHash.new(@path)
      end

      class PathHash < Hash

        def initialize(path)
          @path = path
          super() # don't pass args
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

      def get_cluster(name)
        require_clusters
        @clusters[name]
      end

      def get_blueprint(name)
        require_blueprints
        @blueprints[name]
      end

      def get_hub
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

    end
  end
end