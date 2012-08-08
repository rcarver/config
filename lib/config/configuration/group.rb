module Config
  module Configuration
    # A configuration group is a set of key/value pairs containing the actual
    # data of your configuration.
    #
    # Examples
    #
    #     hash = { name: "Joe", age: 33 }
    #     group = Config::Configuration::Group.new("Global", :person, hash)
    #
    #     group.name # => "Joe"
    #     group.age  # => 33
    #
    class Group
      include Config::Core::Loggable
      include Config::Configuration::MethodMissing

      # Internal: Initialize a new group.
      #
      # level_name        - String name of the level.
      # name              - Symbol name of the group.
      # hash              - Hash of key/values for the group.
      # value_transformer - Proc that takes (key, value) and returns value.
      #
      def initialize(level_name, name, hash = {}, value_transformer = nil)
        @level_name = level_name
        @name = name
        @hash = hash
        @value_transformer = value_transformer || -> key, value { value }
      end

      # Public: Get the value for a key.
      #
      # Returns the value.
      # Raises Config::Configuration::UnknownKey if the key is not defined.
      def [](key)
        if @hash.key?(key)
          value = @hash[key]
          @value_transformer.call(key, value)
        else
          raise UnknownKey, "#{key.inspect} is not defined in #{self}"
        end
      end

      # Public: Determine if a key is defined.
      #
      # Returns a Boolean.
      def defined?(key)
        @hash.key?(key)
      end

      def to_s
        "<Configuration::Group #{@name.inspect} (#{@level_name.inspect})>"
      end

      def _level_name
        @level_name
      end

    end
  end
end
