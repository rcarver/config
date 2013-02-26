module Config
  module Spy
    # Spy::Configuration is an an alternative implementation of
    # Config::Configuration that returns fake values for any group or
    # key that's accessed.
    #
    # Spies can be used to inspect the execution of your Blueprint or
    # Pattern.
    class Configuration < Levels::Configuration

      def self.spy_and_merge(level_name, *levels)
        spy_level = Config::Spy::Configuration::Level.new(level_name)
        config = self.new([spy_level] + levels)
        config.event_handler = Config::Spy::Configuration::EventHandler.new
        config
      end

      def get_accessed_groups
        @event_handler.accesses
      end

      class EventHandler

        def initialize
          @accesses = Hash.new { |h, k| h[k] = [] }
        end

        attr_reader :accesses

        def on_values(values)
          @accesses[values.group_key] << values.value_key
          @accesses[values.group_key].uniq!
        end

        def on_nested_values(values)
          on_values(values)
        end
      end

      class Level < Levels::Level

        def to_s
          "Spy:#{super}"
        end

        # All groups are defined.
        def [](group_key)
          key = Levels::Key.new(group_key)
          Group.new(key)
        end

        # All keys are defined.
        def defined?(group_name)
          true
        end
      end

      class Group < Levels::Group

        def initialize(group_key)
          @group_key = group_key
        end

        def to_s
          "Spy:#{super}"
        end

        # Behave like a String.
        alias to_str to_s

        # All keys exist.
        def [](value_key)
          key = Levels::Key.new(value_key)
          "spy:#{@group_key.to_sym}.#{key.to_sym}"
        end

        # All keys are defined.
        def defined?(value_key)
          true
        end
      end

    end
  end
end
