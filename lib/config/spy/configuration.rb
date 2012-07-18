module Config
  module Spy
    # Spy::Configuration is an an alternative implementation of
    # Config::Configuration that returns fake values for any group or
    # key that's accessed.
    #
    # Spies can be used to inspect the execution of your Blueprint or
    # Pattern.
    class Configuration

      def initialize(configuration = nil)
        @configuration = configuration || Config::Configuration.new
        @groups = {}
      end

      # Internal: Retrieve the groups that have been accessed. Use this
      # to find out what happened.
      #
      # Returns an Array of Config::Spy::Configuration::Group.
      def get_accessed_groups
        @groups.values
      end

      def to_s
        "<Spy Configuration>"
      end

      def [](group_name)
        begin
          Group.new(group_name, @configuration[group_name])
        rescue Config::Configuration::UnknownGroup
          unless group_name.is_a?(Symbol)
            raise ArgumentError, "Group Name must be a Symbol, got #{group_name.inspect}"
          end
          @groups[group_name] ||= Group.new(group_name)
        end
      end

      # Enables dot syntax for groups.
      def method_missing(message, *args, &block)
        raise ArgumentError, "arguments are not allowed: #{message}(#{args.inspect})" if args.any?
        self[message]
      end

      def ==(other)
        get_accessed_groups == other.get_accessed_groups
      end

      class Group
        include Config::Core::Loggable

        def initialize(name, group = nil)
          @name = name
          @group = group || Config::Configuration::Group.new(name)
          @keys = Set.new
        end

        def to_s
          "fake:#{@name}"
        end

        # Behave like a String.
        alias to_str to_s

        # Internal: Retrieve the keys that have been accessed. Use this
        # to find out what happened.
        #
        # Returns an Array of Symbol.
        def get_accessed_keys
          @keys.to_a
        end

        def [](key)
          begin
            @group[key]
          rescue Config::Configuration::UnknownVariable
            unless key.is_a?(Symbol)
              raise ArgumentError, "Key must be a Symbol, got #{key.inspect}"
            end
            @keys << key
            value = "fake:#{@name}.#{key}"
            log << "Read #{@name}.#{key} => #{value.inspect}"
            value
          end
        end

        # Enables dot syntax for keys.
        def method_missing(message, *args, &block)
          raise ArgumentError, "arguments are not allowed: #{message}(#{args.inspect})" if args.any?
          self[message]
        end
      end
    end
  end
end
