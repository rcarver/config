module Config
  module DSL
    # Syntax for Blueprint files, stored at blueprints/[name].rb.
    class BlueprintDSL < Config::Pattern

      desc "The current Node"
      attr :node

      desc "The current Cluster"
      attr :cluster

      def to_s
        "<Blueprint>"
      end

      def inspect
        "<Blueprint>"
      end
    end
  end
end
