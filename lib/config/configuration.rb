module Config
  module Configuration

    # Internal: Shorthand for creating a configuration level.
    def self.new(name = nil)
      Levels::Level.new(name || "[no name]")
    end

    # Internal: Create a merge from one or more configuration levels.
    def self.merge(*levels)
      Levels::Merged.new(levels)
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
