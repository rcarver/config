module Config
  module Spy
    # Spy::Configuration is an an alternative implementation of
    # Config::Configuration that returns fake values for any group or
    # key that's accessed.
    #
    # Spies can be used to inspect the execution of your Blueprint or
    # Pattern.
    class Configuration
      include Config::Configuration::MethodMissing

      def initialize(level_name, parent = nil)
        @level_name = level_name
        @parent = parent || Config::Configuration.merge
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
        "<Spy Configuration #{_level_name}>"
      end

      def _level_name
        @level_name
      end

      def [](group_name)
        assert_symbol group_name
        parent_group = @parent.defined?(group_name) ? @parent[group_name] : nil
        @groups[group_name] ||= Group.new(@level_name, group_name, parent_group)
      end

      def defined?(group_name)
        assert_symbol group_name
        true
      end

      def ==(other)
        _level_name == other._level_name &&
          get_accessed_groups == other.get_accessed_groups
      end

    protected

      def assert_symbol(group_name)
        unless group_name.is_a?(Symbol)
          raise ArgumentError, "Group Name must be a Symbol, got #{group_name.inspect}"
        end
      end

      class Group
        include Config::Configuration::MethodMissing

        def initialize(level_name, name, parent_group = nil)
          @level_name = level_name
          @name = name
          @parent_group = parent_group || Config::Configuration::Group.new(level_name, name)
          @keys = Set.new
        end

        def to_s
          "spy:#{@name}"
        end

        # Behave like a String.
        alias to_str to_s

        def _level_name
          @level_name
        end

        # Internal: Retrieve the keys that have been accessed. Use this
        # to find out what happened.
        #
        # Returns an Array of Symbol.
        def get_accessed_keys
          @keys.to_a
        end

        def [](key)
          assert_symbol key
          raise Config::Configuration::UnknownKey if @parent_group.defined?(key)
          @keys << key
          "spy:#{@name}.#{key}"
        end

        def defined?(key)
          assert_symbol key
          !@parent_group.defined?(key)
        end

      protected

        def assert_symbol(key)
          unless key.is_a?(Symbol)
            raise ArgumentError, "Key must be a Symbol, got #{key.inspect}"
          end
        end

      end
    end
  end
end
