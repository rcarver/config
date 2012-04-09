module Config
  module Core
    class Executor

      def initialize(accumulation)
        @accumulation = accumulation
      end

      def accumulate
        index = 0
        loop do
          size = @accumulation.patterns.size
          slice = @accumulation.patterns.slice(index..-1)
          slice.each do |p|
            p.call
          end
          break if size == @accumulation.patterns.size
          index = size
        end
      end

      def execute
        @accumulation.patterns.each do |p|
          p.execute
        end
      end

    end
  end
end
