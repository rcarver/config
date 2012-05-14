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

    end
  end
end
