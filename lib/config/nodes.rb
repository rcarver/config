module Config
  # This class helps you manage the nodes stored in your database.
  class Nodes

    def initialize(database)
      @database = database
    end

    # Public: Find a node in the database.
    #
    # fqn - String Node FQN.
    #
    # Returns a Config::Node or nil.
    def find_node(fqn)
      @database.find_node(fqn)
    end

    # TODO:
    # def find_all_nodes

    # Public: Update the stored node data by inspecting the current
    # execution environment.
    #
    # fqn         - String Node FQN.
    # fact_finder - Callable object that returns Config::Core::Facts.
    #
    # Returns a Config::Node.
    def update_node(fqn, fact_finder)
      node = find_node(fqn) || Config::Node.from_fqn(fqn)
      node.facts = fact_finder.call
      @database.update_node(node)
      node
    end

    # Public: Remove the node from the database.
    #
    # fqn - String Node FQN.
    #
    # Returns nothing.
    def remove_node(fqn)
      node = find_node(fqn)
      @database.remove_node(node) if node
      nil
    end
  end
end
