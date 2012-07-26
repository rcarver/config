module Config
  class Project

    UnknownNode = Class.new(StandardError)
    UnknownCluster = Class.new(StandardError)
    UnknownBlueprint = Class.new(StandardError)

    def initialize(loader, database, nodes)
      @loader = loader
      @database = database
      @nodes = nodes
    end

    # Update to the latest version of the database.
    #
    # Returns nothing.
    def update_database
      @database.update
    end

    # Update the information about a node and store it in the database.
    #
    # Returns nothing.
    def update_node(fqn)
      # TODO: facts could be configurable to use ohai or something else.
      @nodes.update_node(fqn, -> { Config::Core::Facts.invent })
    end

    # Determine if a cluster exists.
    #
    # name - String name of the cluster.
    #
    # Returns a Boolean.
    def cluster?(name)
      !! @loader.get_cluster(name)
    end

    # Determine if a blueprint exists.
    #
    # name - String name of the blueprint.
    #
    # Returns a Boolean.
    def blueprint?(name)
      !! @loader.get_blueprint(name)
    end

    # Get the top level settings as defined by `config.rb`
    #
    # Returns a Config::ProjectSettings.
    def base_settings
      Config::ProjectSettings.new(merged_configuration)
    end

    # Get the settings for a cluster, as defined by `config.rb` and the
    # cluster configuration.
    #
    # cluster_name - String name of the cluster.
    #
    # Returns a Config::ProjectSettings.
    def cluster_settings(cluster_name)
      cluster = get_cluster(cluster_name)
      Config::ProjectSettings.new(merged_configuration(cluster))
    end

    # Get the settings for a node, as defined by `config.rb`, the
    # cluster configuration and the node configuration.
    #
    # fqn - String the node fqn.
    #
    # Returns a Config::ProjectSettings.
    def node_settings(fqn)
      node = get_node(fqn)
      cluster = get_cluster(node.cluster_name)
      Config::ProjectSettings.new(merged_configuration(cluster, node))
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

    def get_global
      @loader.get_global || Config::Global.new
    end

    def get_cluster(name)
      @loader.get_cluster(name) or raise UnknownCluster, "Cluster #{name.inspect} was not found"
    end

    def get_blueprint(name)
      @loader.get_blueprint(name) or raise UnknownBlueprint, "Blueprint #{name.inspect} was not found"
    end

    def get_node(name)
      @nodes.get_node(name) or raise UnknownNode, "Node #{name.inspect} was not found"
    end

    def merged_configuration(cluster = nil, node = nil)
      configs = []
      configs << get_global.configuration
      configs << cluster.configuration if cluster
      #configs << node.configuration if node
      configs.inject(Config::Configuration.new) { |a, config| a + config }
    end

  end
end
