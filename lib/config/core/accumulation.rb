module Config
  module Core
    class Accumulation
      include Config::Core::Loggable
      include Enumerable

      def self.from_file(path)
        from_string File.read(path)
      end

      def self.from_string(string)
        new Marshal.restore(string)
      end

      def initialize(patterns=[])
        @patterns = patterns
        @current = nil
      end

      # Instantiate and add a Pattern class.
      #
      # parent - A Config::Pattern to define the parent/child
      #          relationship.
      # klass  - A sub-Class of Config::Pattern.
      #
      # Yields the instantiated Pattern if a block is given.
      #
      # Returns the instantiated Pattern.
      def add_pattern(parent, klass)
        pattern = klass.new
        yield pattern if block_given?
        pattern.accumulation = self
        pattern.parent = parent
        self << pattern
        pattern
      end

      # Public: Get a new instance containing only the
      # patterns that do NOT exist in the given Accumulation.
      #
      # accumulation - Config:Core::Accumulation.
      #
      # Returns a Config::Core::Accumulation.
      def -(accumulation)
        accumulation = self.class.new(to_a - accumulation.to_a)
        accumulation
      end

      # Public: Store this accumulation on disk so that it can be
      # restored later.
      #
      # path - String path of the file.
      #
      # Returns nothing.
      def write_to_file(path)
        File.open(path, "w") do |f|
          f.print serialize
        end
      end

      # Internal: Serialize the current patterns.
      def serialize
        Marshal.dump(@patterns)
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
