module Config
  module Core
    class Accumulation
      include Config::Core::Loggable
      include Enumerable

      def initialize
        @current = nil
        @patterns = []
      end

      # Public: Instantiate and add a Pattern class.
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
        pattern.log = log
        self << pattern
        pattern
      end

      # Internal: Set the current parent pattern. This
      # pattern will be passed to newly added patterns
      # to define their hierarchy.
      attr_writer :current

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

      # Internal: Iterate over the Patterns.
      def each(&block)
        @patterns.each(&block)
      end

    end
  end
end
