module Config
  module Core
    class ValidationError < StandardError

      def initialize(errors)
        @errors = errors
      end

      attr_reader :errors

      def message
        @errors.join(", ")
      end
    end
  end
end
