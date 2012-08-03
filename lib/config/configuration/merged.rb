module Config
  module Configuration
    class Merged

      def initialize(levels)
        @levels = levels
      end

      def [](group_name)
        levels = @levels.reverse.find_all { |level| level.defined?(group_name) }
        raise UnknownGroup if levels.empty?

        groups = levels.map { |level| level[group_name] }
        Config::Configuration::MergedGroup.new(group_name, groups)
      end

      def defined?(group_name)
        @levels.any? { |level| level.defined?(group_name) }
      end

      def to_s
        "<Configuration::Merged #{@levels.map { |l| l.name }.join(', ')}>"
      end

    end
  end
end
