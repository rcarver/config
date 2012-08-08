module Config
  module Configuration
    # Merging is the union if one or more configuration levels.
    class Merged
      include Config::Configuration::MethodMissing

      # Internal: Initialze a new merge.
      #
      # levels - Array of Config::Configuration::Level.
      #
      def initialize(levels)
        @levels = levels
      end

      # See Config::Configuration::Level#[].
      def [](group_name)
        levels = @levels.find_all { |level| level.defined?(group_name) }
        raise UnknownGroup if levels.empty?

        groups = levels.map { |level| level[group_name] }
        Config::Configuration::MergedGroup.new(group_name, groups)
      end

      # See Config::Configuration::Level#defined?.
      def defined?(group_name)
        @levels.any? { |level| level.defined?(group_name) }
      end

      def to_s
        "<Configuration::Merged #{@levels.map { |l| l._level_name }.join(', ')}>"
      end

    end
  end
end
