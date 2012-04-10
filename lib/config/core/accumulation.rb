module Config
  module Core
    class Accumulation

      class ValidationError < StandardError

        def initialize(errors)
          @errors = errors
        end

        attr_reader :errors

        def message
          @errors.join(", ")
        end
      end

      class ConflictError < StandardError

        def initialize(a, b)
          @pattern1 = a
          @pattern2 = b
        end

        attr_reader :pattern1
        attr_reader :pattern2

        def message
          "#{pattern1}: #{pattern1.attributes.inspect} vs. #{pattern2}: #{pattern2.attributes.inspect}"
        end
      end

      include Enumerable

      def initialize
        @current = nil
        @patterns = []
      end

      # Internal: Add a Pattern.
      def <<(pattern)
        @patterns << pattern
      end

      # Internal: Get the Patterns.
      def to_a
        @patterns
      end

      # Internal: The number of Patterns.
      def size
        @patterns.size
      end

      def each(&block)
        @patterns.each(&block)
      end

      # Internal: Set the current parent pattern. This
      # pattern will be passed to newly added patterns
      # to define their hierarchy.
      attr_writer :current

      # Internal: Instantiate and add a Pattern class.
      #
      # klass - A subclass of Config::Pattern.
      #
      # Yields the instantiated Pattern if a block is given.
      #
      # Returns the instantiated Pattern.
      def add(klass)
        pattern = klass.new(self)
        yield pattern if block_given?
        pattern.parent = @current
        self << pattern
        pattern
      end

      def validate!
        errors = []
        each do |pattern|
          errors.concat pattern.error_messages
        end
        raise ValidationError, errors if errors.any?
      end

      def resolve!
        group = Hash.new { |h, k| h[k] = [] }

        # Group patterns with equivalent keys.
        each do |pattern|
          group[pattern] << pattern
        end

        # If there are multiple patterns for a key, determine
        # if they are in conflict or duplicates.
        group.each do |patterns|
          next if patterns.size == 1

          # Check the patterns against each other.
          first, others = *patterns
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

      def destroy_missing_patterns(previous_patterns)
        raise NotImplementedError
      end

    end
  end
end
