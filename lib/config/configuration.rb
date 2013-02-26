module Config
  module Configuration

    # Internal: Shorthand for creating a configuration level.
    def self.new(name = nil)
      Levels::Level.new(name || "[no name]")
    end

    # Internal: Create a merge from one or more configuration levels.
    def self.merge(*levels)
      merged = Levels::Configuration.new(levels)
      merged.event_handler = EventHandler.new
      merged
    end

    class EventHandler
      include Config::Core::Loggable

      def initialize
        @base_color = :magenta
        @alt_color  = :cyan
      end

      def on_values(values, recursing = false)
        if values.only_final? && !values.recursive? && !recursing
          final = values.final
          log << log.colorize("Read #{values.group_key}.#{values.value_key} => #{final.inspect} from #{final.level_name}", @base_color)
        else
          log << log.colorize("Read #{values.group_key}.#{values.value_key}", @base_color)
          log.indent do
            values.each do |value|
              value.notify(self)
              if value.final?
                word = "Use "
                color = @base_color
              else
                word = "Skip"
                color = @alt_color
              end
              log << log.colorize("#{word} #{value.inspect} from #{value.level_name}", color)
            end
          end
        end
      end

      def on_nested_values(values)
        log.indent do
          on_values(values, true)
        end
      end
    end

    # Enables dot syntax for levels and groups.
    module MethodMissing
      def method_missing(message, *args, &block)
        raise ArgumentError, "arguments are not allowed: #{message}(#{args.inspect})" if args.any?
        if message =~ /^(.*)\?$/
          self.defined?($1.to_sym)
        else
          self[message]
        end
      end
    end
  end
end
