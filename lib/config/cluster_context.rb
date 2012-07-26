module Config
  # This class exposes a cluster for use within a Blueprint. Its main
  # pupose is to let you operate on all of the nodes within the cluster.
  class ClusterContext

    def initialize(cluster, nodes)
      @cluster = cluster
      @nodes = nodes
    end

    # Public: Get the name of the cluster.
    #
    # Returns a String.
    def name
      @cluster.name
    end

    # Public: Get a node by its FQN.
    #
    # fqn - String the Node FQN.
    #
    # Returns a Config::Node or nil.
    def get_node(fqn)
      node = @nodes.get_node(fqn)
      node if context?(node)
    end

    # Public: Find a single node matching a search. The node must also
    # belong to the cluster.
    #
    # args - Search arguments. See Config::Nodes#find_node.
    #
    # Returns a Config::Node or nil.
    # Raises Config::Nodes::Ambiguous node if the search returns more
    #   than one result.
    def find_node(*args)
      node = @nodes.find_node(*args)
      node if context?(node)
    end

    # Public: Find all ndoes matching a search. The returned nodes will
    # all belong to this cluster.
    #
    # args - Search arguments. See Config::Nodes#find_all_nodes
    #
    # Returns an Array of Config::Node.
    def find_all_nodes(*args)
      nodes = @nodes.find_all_nodes(*args)
      nodes.find_all { |n| context?(n) }
    end

  protected

    def context?(node)
      node && node.cluster_name == name
    end

  end
end
