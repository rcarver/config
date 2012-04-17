module Config
  module Core
    class Variables
      include Loggable

      UnknownVariable = Class.new(StandardError)

      def initialize(name, variables={})
        @name = name
        @variables = variables
      end

      def to_s
        "[Variables #{@name.inspect}]"
      end

      def [](key)
        if @variables.key?(key)
          value = @variables[key]
          log << "Read #{@name}.#{key} => #{value.inspect}"
          value
        else
          raise UnknownVariable, "#{key.to_s} is not defined in #{self}"
        end
      end

      def method_missing(message, *args, &block)
        raise ArgumentError, "arguments are not allowed" if args.any?
        self[message]
      end

    end
  end
end
