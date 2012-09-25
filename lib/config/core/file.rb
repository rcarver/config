module Config
  module Core
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

      # Get the basename of the file (the name excluding the extension).
      #
      # Returns a String.
      def basename
        @path.basename(@path.extname).to_s
      end

      # Determine if the file exists on disk.
      #
      # Returns a Boolean.
      def exist?
        @path.exist?
      end

      # Read the file contents from disk.
      #
      # Returns a String or nil.
      def read
        @path.read if exist?
      end

      # Write file contents to disk.
      #
      # string - String to write.
      #
      # Returns nothing.
      def write(string)
        @path.dirname.mkpath
        @path.open("w") { |f| f.print string }
      end
    end
  end
end
