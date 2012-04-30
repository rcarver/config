module Config
  class Project

    UnknownCluster = Class.new(StandardError)
    UnknownBlueprint = Class.new(StandardError)

    def initialize(dir)
      @dir = Pathname.new(dir).cleanpath
      @clusters = {}
      @blueprints = {}
    end

    attr :clusters
    attr :blueprints

    def try_blueprint(blueprint_name, cluster_name)
      require_all

      blueprint = blueprints[blueprint_name]
      blueprint or raise UnknownBlueprint, "Blueprint #{blueprint_name} was not found"

      cluster = clusters[cluster_name]
      cluster or raise UnknownCluster, "Cluster #{cluster_name} was not found"

      blueprint.configuration = cluster.configuration

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
