module Config
  module Core
    module Changeable

      def changed!(msg)
        @changed = true
        log.indent do
          log << msg
        end
      end

      def changed?
        !!@changed
      end

    end
  end
end
