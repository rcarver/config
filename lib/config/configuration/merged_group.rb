module Config
  module Configuration
    # A merged group contains the union of keys from a set of groups. However,
    # the value of a key is the value of the last group.
    class MergedGroup
      include Config::Core::Loggable
      include Config::Configuration::MethodMissing

      # Internal: Initialize a merged group.
      #
      # name   - Symbol the group name.
      # groups - Array of Config::Configuration::Group.
      #
      def initialize(name, groups)
        @name = name
        @groups = groups
      end

      # See Config::Configuration::Group#[].
      def [](key)
        groups = @groups.find_all { |group| group.defined?(key) }
        raise UnknownKey if groups.empty?

        group = groups.last
        value = group[key]

        base_color = :magenta
        alt_color  = :cyan

        if groups.size == 1
          log << log.colorize("Read #{@name}.#{key} => #{value.inspect} from #{group._level_name}", base_color)
        else
          log << log.colorize("Read #{@name}.#{key}", base_color)
          log.indent do
            groups.each.with_index do |g, index|
              value = g[key]
              if index == groups.size - 1
                word = "Use "
                color = base_color
              else
                word = "Skip"
                color = alt_color
              end
              log << log.colorize("#{word} #{value.inspect} from #{g._level_name}", color)
            end
          end
        end

        value
      end

      # See Config::Configuration::Group#defined?
      def defined?(key)
        @groups.any? { |group| group.defined?(key) }
      end

      def to_s
        "<Configuration::MergedGroup #{name}>"
      end
    end
  end
end
