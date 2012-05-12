module Config
  module Data
    class Secret

      def initialize(file)
        @file = Pathname.new(file)
      end

      # Read the secret from disk.
      #
      # Returns a String or nil.
      def read
        @file.read if @file.exist?
      end

    end
  end
end
