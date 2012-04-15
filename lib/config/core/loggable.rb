module Config
  module Core
    module Loggable

      # Public: Get the logger.
      #
      # Returns a Config::Log.
      def log
        @log ||= Config.log
      end

      # Public: Set the logger.
      #
      # log - Config::Log
      #
      # Returns nothing.
      def log=(log)
        @log = log
      end

    end
  end
end
