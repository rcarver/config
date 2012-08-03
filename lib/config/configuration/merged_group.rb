module Config
  module Configuration
    class MergedGroup

      def initialize(name, groups)
        @name = name
        @groups = groups
      end

      def [](key)
        groups = @groups.find_all { |group| group.defined?(key) }
        raise UnknownVariable if groups.empty?

        if groups.size > 1
          groups[0..-1].each.with_index do |group, index|
            log.indent(index) do
              log << "Skipped #{key} in #{group}"
            end
          end
        end

        group = groups.last
        value = group[key]
        log << "Read #{@name}.#{key} => #{value.inspect} from #{group.to_s}"
        value
      end

      def defined?(key)
        @groups.any? { |group| group.defined?(key) }
      end

      def to_s
        "<Configuration::MergedGroup #{name}>"
      end
    end
  end
end
