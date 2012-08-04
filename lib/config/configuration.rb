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
    UnknownVariable = Class.new(StandardError)

    def self.new(name = nil)
      Level.new(name || "[no name]")
    end

    def self.merge(*levels)
      Merged.new(levels)
    end

    module MethodMissing

      # Enables dot syntax for keys.
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
