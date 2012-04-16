module Config
  module Core
    module Loggable

      # Public: Get the logger.
      #
      # Returns a Config::Log.
      def log
        @log ||= Config.log
      end
    end
  end
end
