module Config
  module DSL
    # Syntax for Cluster files, stored at clusters/[name].rb. A cluster
    # is used to define variables for use by blueprints.
    class ClusterDSL

      def initialize
        @variables = {}
      end

      # Public: Define configuration variables.
      #
      # name - Symbol name of the group.
      # hash - Hash of Symbol keys and any values.
      #
      # Returns nothing.
      def configure(name, hash)
        @variables[name.to_sym] = Config::Core::Variables.new(name, hash)
      end

      attr :variables

      def to_s
        "<Cluster>"
      end

      def inspect
        "<Cluster>"
      end
    end
  end
end
