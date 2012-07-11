module Config
  class Project

    UnknownNode = Class.new(StandardError)
    UnknownCluster = Class.new(StandardError)
    UnknownBlueprint = Class.new(StandardError)

    def initialize(loader, data, nodes)
      @loader = loader
      @data = data
      @nodes = nodes
    end

    def cluster?(name)
      !! @loader.get_cluster(name)
    end

    def blueprint?(name)
      !! @loader.get_blueprint(name)
    end

    # This is a bash implementation of #update It's written in bash so that it
    # can be used during the bootstrap process. It's stored here so that it can
    # be used both in the config-update-project command and the node-based
    # config-run command. It's also stored here so that the script is visible
    # alongside logically similar code.
    #
    # Returns a String.
    def update_project_script
      <<-STR
# Require that the working directory has no uncommited changes.
if [ -n "$(git status --porcelain)" ]; then
  echo "git repo is not totally clean." >&2
  exit 1
fi

# Pull in the latest changes cleanly.
git pull --rebase
      STR
    end

    # Execute the node's blueprint.
    #
    # fqn - String Node FQN.
    #
    # Returns a Config::Node.
    def execute_node(fqn, previous_accumulation = nil)
      @loader.require_all

      node = get_node(fqn)
      cluster = get_cluster(node.cluster_name)
      blueprint = get_blueprint(node.blueprint_name)

      # Configure.
      blueprint.facts = node.facts
      blueprint.configuration = merged_configuration(cluster, node)
      blueprint.previous_accumulation = previous_accumulation if previous_accumulation

      # Execute.
      accumulation = blueprint.accumulate
      blueprint.validate
      blueprint.execute

      accumulation
    end

    # Execute a blueprint in noop mode.
    #
    # blueprint_name - String name of the blueprint.
    # cluster_name   - String name of the cluster (default: execute with
    #                  a Spy cluster)
    #
    # Returns nothing.
    def try_blueprint(blueprint_name, cluster_name = nil)
      @loader.require_all

      blueprint = get_blueprint(blueprint_name)

      # Configure.
      if cluster_name
        cluster = get_cluster(cluster_name)
        blueprint.configuration = merged_configuration(cluster)
      else
        blueprint.configuration = Config::Spy::Configuration.new(merged_configuration)
      end
      blueprint.facts = Config::Spy::Facts.new

      # Execute.
      accumulation = blueprint.noop!
      blueprint.validate
      blueprint.execute

      accumulation
    end

  protected

    def get_self
      @loader.get_self || Config::Self.new
    end

    def get_cluster(name)
      @loader.get_cluster(name) or raise UnknownCluster, "Cluster #{name.inspect} was not found"
    end

    def get_blueprint(name)
      @loader.get_blueprint(name) or raise UnknownBlueprint, "Blueprint #{name.inspect} was not found"
    end

    def get_node(name)
      @nodes.find_node(name) or raise UnknownNode, "Node #{name.inspect} was not found"
    end

    def merged_configuration(cluster = nil, node = nil)
      configs = []
      configs << get_self.configuration
      configs << cluster.configuration if cluster
      #configs << node.configuration if node
      configs.inject(Config::Configuration.new) { |a, config| a + config }
    end

  end
end
