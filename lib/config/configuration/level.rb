module Config
  module Configuration
    class Level
      include Config::Configuration::MethodMissing

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

