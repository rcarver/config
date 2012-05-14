module Config
  module Data
    class File

      def initialize(path)
        @path = Pathname.new(path)
      end

      # Get the path of the file.
      #
      # Returns a String.
      def path
        @path.cleanpath.to_s
      end

      # Get the name of the file.
      #
      # Returns a String.
      def name
        @path.basename.to_s
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
