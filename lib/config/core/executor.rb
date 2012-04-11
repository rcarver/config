module Config
  module Core
    class Executor

      def initialize(accumulation)
        @accumulation = accumulation
      end

      def accumulate
        index = 0
        loop do
          size = @accumulation.size
          slice = @accumulation.to_a.slice(index..-1)
          slice.each do |p|
            p.call
          end
          break if size == @accumulation.size
          index = size
        end
      end

      def validate!
        errors = []
        @accumulation.each do |pattern|
          errors.concat pattern.error_messages
        end
        raise ValidationError, errors if errors.any?
      end

      def resolve!
        group = Hash.new { |h, k| h[k] = [] }

        # Group patterns with equivalent keys.
        @accumulation.each do |pattern|
          group[pattern] << pattern
        end

        # If there are multiple patterns for a key, determine
        # if they are in conflict or duplicates.
        group.values.each do |patterns|
          next if patterns.size == 1

          # Check the patterns against each other.
          first, *others = patterns
          others.each do |other|

            # If the two patterns are in conflict, abort.
            if first.conflict?(other)
              raise ConflictError.new(first, other)
            end

            # If the two patterns are equivalent,
            # skip the extra one.
            if first == other
              other.run_mode = :skip
            end
          end
        end
      end

      attr_writer :previous_accumulation

      def execute
        if @previous_accumulation
          missing_patterns = @previous_accumulation - @accumulation
          missing_patterns.each do |p|
            p.run_mode = :destroy
            p.execute
          end
        end
        @accumulation.each do |p|
          p.execute
        end
      end
    end
  end
end
