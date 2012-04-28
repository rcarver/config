module Config
  module DSL
    # Syntax for Cluster files, stored at clusters/[name].rb. A cluster
    # is used to define the configuration for use by blueprints.
    class ClusterDSL

      def initialize
        @configuration = Config::Core::Configuration.new
      end

      # Public: Define configuration variables.
      #
      # name - Symbol name of the group.
      # hash - Hash of Symbol keys and any values.
      #
      # Returns nothing.
      def configure(name, hash)
        @configuration.set_group(name, hash)
      end

      def to_s
        "<Cluster>"
      end

      def inspect
        "<Cluster>"
      end

      def _get_configuration
        @configuration
      end
    end
  end
end
