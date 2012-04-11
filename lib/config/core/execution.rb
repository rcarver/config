module Config
  module Core
    class Execution
      include Enumerable

      def self.from_file(path)
        from_string File.read(path)
      end

      def self.from_string(string)
        new Marshal.restore(string)
      end

      def initialize(patterns)
        @patterns = patterns
      end

      def -(execution)
        self.class.new(to_a - execution.to_a)
      end

      def each(&block)
        @patterns.each(&block)
      end

      def write_to_file(path)
        File.open(path, "w") do |f|
          f.print serialize
        end
      end

      def serialize
        Marshal.dump(@patterns)
      end

      def to_a
        @patterns.to_a
      end

      def ==(other)
        to_a == other.to_a
      end

    end
  end
end
