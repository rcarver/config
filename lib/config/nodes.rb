module Config
  # This class helps you manage the nodes stored in your database.
  class Nodes

    # Exception raised if you perform query and expect a single node but
    # more than one node is returned.
    AmbiguousNode = Class.new(StandardError)

    def initialize(database)
      @database = database
    end

    # Public: Get a node from the database.
    #
    # fqn - String Node FQN.
    #
    # Returns a Config::Node or nil.
    def get_node(fqn)
      @database.all_nodes.find { |node| node.fqn == fqn }
    end

    # Public: Find a single node.
    #
    # args - TBD parameters to match against.
    #
    # Returns a Config::Node or nil.
    # Raises AmbiguousNode if more than one node matches the parameters.
    def find_node(*args)
      nodes = find_all_nodes(*args)
      raise AmbiguousNode if nodes.size > 1
      nodes.first
    end

    # Public: Find all nodes.
    #
    # args - TBD parameters to match against.
    #
    # Returns an Array of Config::Node.
    def find_all_nodes(*args)
      raise NotImplementedError
      nodes = @database.all_nodes
      # TODO: design node finder syntax
      nodes
    end

    # Public: Update the stored node data by inspecting the current
    # execution environment.
    #
    # fqn   - String Node FQN.
    # facts - Config::Facts to store for the node.
    #
    # Returns a Config::Node.
    def update_node(fqn, facts)
      node = get_node(fqn) || Config::Node.from_fqn(fqn)
      node.facts = facts
      @database.update_node(node)
      node
    end

    # Public: Remove the node from the database.
    #
    # fqn - String Node FQN.
    #
    # Returns nothing.
    def remove_node(fqn)
      node = get_node(fqn)
      @database.remove_node(node) if node
      nil
    end
  end
end
