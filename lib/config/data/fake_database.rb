module Config
  module Data
    # An in memory database implementation for testing.
    class FakeDatabase

      def initialize(nodes)
        @nodes = {}
        nodes.each do |node|
          @nodes[node.fqn] = node
        end
      end

      def find_node(fqn)
        @nodes[fqn]
      end

      def update_node(node)
        @nodes[node.fqn] = node
      end

      def remove_node(node)
        @nodes.delete(node.fqn)
      end
    end
  end
end
