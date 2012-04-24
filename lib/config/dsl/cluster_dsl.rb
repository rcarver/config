module Config
  module DSL
    # Syntax for Cluster files, stored at clusters/[name].rb.
    class ClusterDSL

      def initialize
        @variables = {}
      end

      attr :variables

      def configure(name, hash)
        @variables[name.to_sym] = Config::Core::Variables.new(name, hash)
      end

      def to_s
        "<Cluster>"
      end

      def inspect
        "<Cluster>"
      end
    end
  end
end
