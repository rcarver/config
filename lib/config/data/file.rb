module Config
  module Data
    class File

      def initialize(path)
        @path = Pathname.new(path)
      end

      # Read the file contents from disk.
      #
      # Returns a String or nil.
      def read
        @path.read if @path.exist?
      end

      # Write file contents to disk.
      #
      # string - String to write.
      #
      # Returns nothing.
      def write(string)
        @path.open("w") { |f| f.print string }
      end
    end
  end
end
