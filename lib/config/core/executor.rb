module Config
  module Core
    # This class executes the patterns found in a Config::Core::Accumulation.
    # This process involves several phases:
    #
    # 1. Validate. Ensure that all patterns have been defined properly.
    # 2. Resolve. Ensure that there are no conflicting or duplicate patterns.
    # 3. Execute. Perform the operations of each pattern.
    class Executor

      def initialize(accumulation)
        @accumulation = accumulation
      end

      def validate!
        errors = []
        @accumulation.each do |pattern|
          pattern.validate
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

      def execute(previous_accumulation = nil)
        if previous_accumulation
          missing_patterns = previous_accumulation - @accumulation
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
