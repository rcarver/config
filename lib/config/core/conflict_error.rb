module Config
  module Core
    class ConflictError < StandardError

      def initialize(a, b)
        @pattern1 = a
        @pattern2 = b
      end

      attr_reader :pattern1
      attr_reader :pattern2

      def message
        "[#{pattern1}] #{pattern1.attributes.inspect} vs. #{pattern2}: #{pattern2.attributes.inspect}"
      end
    end
  end
end
