module Config
  module Configuration
    # A configuration level is a collection of groups. Your configuration will
    # typically involve multiple levels such as base, cluster and node. Each
    # level is stored separately so that, for example, when a lower level
    # overrides the values at a higher level the behavior is clear and
    # traceable. Levels are combined via the Config::Configuration::Merged
    # model which defines the override and union symantics.
    class Level
      include Config::Configuration::MethodMissing

      # Internal: Initialize a new level.
      #
      # name - String name of the level.
      #
      def initialize(name)
        @name = name
        @groups = {}
      end

      # Public: Get a group by name.
      #
      # group_name - Symbol name of the group.
      #
      # Returns a Config::Configuration::Group.
      # Raises Config::Configuration::UnknownGroup if the group is not defined.
      def [](group_name)
        @groups[group_name] or raise UnknownGroup, "#{group_name} group is not defined"
      end

      # Public: Determine if a group has been defined.
      #
      # Returns a Boolean.
      def defined?(group_name)
        @groups.key?(group_name)
      end

      # Internal: Define a group.
      #
      # group_name - Symbol name of the group.
      # hash       - Hash of values.
      #
      # Returns nothing.
      def set_group(group_name, hash)
        if @groups[group_name.to_sym]
          raise DuplicateGroup, "#{group_name} has already been defined"
        end
        @groups[group_name.to_sym] = Group.new(@name, group_name.to_sym, hash)
      end

      def to_s
        "<Configuration::Level #{@name.inspect}>"
      end

      def _level_name
        @name
      end

    end
  end
end

