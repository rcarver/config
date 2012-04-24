module Config
  module DSL
    # Syntax for Node files, stored at clusters/[cluster]/[node_id].rb.
    # A node is used to define variables that override those of its
    # cluster so that you may further refine its behavior.
    class NodeDSL

      def to_s
        "<Node>"
      end

      def inspect
        "<Node>"
      end
    end
  end
end

