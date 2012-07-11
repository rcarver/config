module Config
  # The configuration is a collection key/value pairs organized into groups.
  # Each group should define a single resource to be made available to
  # blueprints.
  class Configuration

    # Error thrown if a group is defined more than once.
    DuplicateGroup = Class.new(StandardError)

    # Error thrown when attempting to access a group that has not been defined.
    UnknownGroup = Class.new(StandardError)

    # Error thrown when attempting to read a key that has not been defined.
    UnknownVariable = Class.new(StandardError)

    def initialize
      @groups = {}
    end

    def to_s
      "<Configuration>"
    end

    def set_group(group_name, hash)
      if @groups[group_name.to_sym]
        raise DuplicateGroup, "#{group_name} has already been defined"
      end
      @groups[group_name.to_sym] = Group.new(group_name.to_sym, hash)
    end

    def [](group_name)
      @groups[group_name] or raise UnknownGroup, "#{group_name} group is not defined"
    end

    # Enables dot syntax for groups.
    def method_missing(message, *args, &block)
      raise ArgumentError, "arguments are not allowed: #{message}(#{args.inspect})" if args.any?
      self[message]
    end

    def +(other)
      configuration = Config::Configuration.new
      groups = Hash.new { |h,k| h[k] = {} }
      [self, other].each do |config|
        config._groups.each { |name, group| groups[name].update(group._hash) }
      end
      groups.each do |name, data|
        configuration.set_group(name, data)
      end
      configuration
    end

    def _groups
      @groups
    end

    class Group
      include Config::Core::Loggable

      def initialize(name, hash={})
        @name = name
        @hash = hash
      end

      def _hash
        @hash
      end

      def to_s
        "[Configure #{@name.inspect}]"
      end

      def [](key)
        if @hash.key?(key)
          value = @hash[key]
          log << "Read #{@name}.#{key} => #{value.inspect}"
          value
        else
          raise UnknownVariable, "#{key.to_s} is not defined in #{self}"
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
