module Config
  class ProjectLoader

    def initialize(path)
      @path = Pathname.new(path).cleanpath

      @global = nil
      @clusters = PathHash.new(@path)
      @blueprints = PathHash.new(@path)
    end

    # Internal.
    attr_reader :path

    # Internal.
    def chdir(&block)
      Dir.chdir(@path, &block) if @path.exist?
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

    def get_global
      require_global
      @global
    end

    def get_cluster(name)
      require_clusters
      @clusters[name]
    end

    def get_blueprint(name)
      require_blueprints
      @blueprints[name]
    end

    def require_all
      require_patterns
      require_global
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

    def require_global
      return if @required_global; @required_global = true

      file = Config::Core::File.new(@path + "config.rb")
      if file.exist?
        @global = Config::Global.from_string(file.read, file.path)
      end
    end

    def require_clusters
      return if @required_clusters; @required_clusters = true

      Dir[(@path + "clusters/*.rb")].each do |path|
        file = Config::Core::File.new(path)
        cluster = Cluster.from_string(
          file.basename,
          file.read,
          file.path
        )
        @clusters[cluster.name] = cluster
      end
    end

    def require_blueprints
      return if @required_blueprints; @required_blueprints = true

      Dir[(@path + "blueprints/*.rb")].each do |path|
        file = Config::Core::File.new(path)
        blueprint = Blueprint.from_string(
          file.basename,
          file.read,
          file.path
        )
        @blueprints[blueprint.name] = blueprint
      end
    end

  end
end
