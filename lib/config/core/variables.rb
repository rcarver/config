module Config
  module Core
    class Variables

      UnknownVariable = Class.new(StandardError)

      def initialize(variables={})
        @variables = variables
      end

      def [](key)
        begin
          @variables.fetch(key)
        rescue KeyError
          raise UnknownVariable, "Unknown variable #{key.to_s}"
        end
      end

      def method_missing(message, *args, &block)
        raise ArgumentError, "arguments are not allowed" if args.any?
        self[message]
      end

    end
  end
end
