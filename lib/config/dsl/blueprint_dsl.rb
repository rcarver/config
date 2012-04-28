module Config
  module DSL
    # Syntax for Blueprint files, stored at blueprints/[name].rb.
    # Syntactically, a Blueprint is a special Pattern from which you may
    # access the current Node and current Cluster.
    class BlueprintDSL < Config::Pattern

      # Public: Get the current node.
      #
      # Returns a Config::Node.
      attr_reader :node

      # Public: Get the current configuration.
      #
      # Returns a Config::Core::Variables.
      attr_reader :configure

      def to_s
        "<Blueprint>"
      end

      def inspect
        "<Blueprint>"
      end

      def _set_facts(facts)
        @node = facts
      end

      def _set_configuration(configuration)
        @configure = configuration
      end
    end
  end
end
