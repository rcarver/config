module Config
  module Core
    class Executor

      def initialize(accumulator)
        @accumulator = accumulator
      end

      def call
        index = 0
        loop do
          size = @accumulator.patterns.size
          slice = @accumulator.patterns.slice(index..-1)
          slice.each do |p|
            p.call
          end
          break if size == @accumulator.patterns.size
          index = size
        end
      end

      def execute
        @accumulator.patterns.each do |p|
          p.execute
        end
      end

    end
  end
end
