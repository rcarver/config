module Config
  # The configuration is a collection key/value pairs organized into groups.
  # Each group should define a single resource to be made available to
  # blueprints.
  module Configuration

    # Error thrown if a group is defined more than once.
    DuplicateGroup = Class.new(StandardError)

    # Error thrown when attempting to access a group that has not been defined.
    UnknownGroup = Class.new(StandardError)

    # Error thrown when attempting to read a key that has not been defined.
    UnknownKey = Class.new(StandardError)

    # Internal: Shorthand for creating a configuration level.
    def self.new(name = nil)
      Level.new(name || "[no name]")
    end

    # Internal: Create a merge from one or more configuration levels.
    def self.merge(*levels)
      Merged.new(levels)
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
