module Config
  module Core
    class Accumulation
      include Enumerable

      def self.from_string(string)
        new Marshal.restore(string)
      end

      def initialize(patterns=[])
        @patterns = patterns
        @current = nil
      end

      # Public: Add a pattern.
      #
      # pattern - Config::Pattern.
      #
      # Returns nothing.
      def <<(pattern)
        @patterns << pattern
      end

      # Public: Get a new instance containing only the
      # patterns that do NOT exist in the given Accumulation.
      #
      # accumulation - Config:Core::Accumulation.
      #
      # Returns a Config::Core::Accumulation.
      def -(accumulation)
        self.class.new(to_a - accumulation.to_a)
      end

      # Internal: Serialize the current patterns.
      def serialize
        Marshal.dump(@patterns)
      end

      # Internal: Get the Patterns.
      def to_a
        @patterns
      end

      # Internal: The number of Patterns.
      def size
        @patterns.size
      end

      # Internal: Clear the current Patterns.
      def clear
        @patterns.clear
      end

      # Internal: Iterate over the Patterns.
      def each(&block)
        @patterns.each(&block)
      end

      # Internal: Equality.
      def ==(other)
        to_a == other.to_a
      end
    end
  end
end
