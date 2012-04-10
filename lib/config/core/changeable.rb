module Config
  module Core
    module Changeable

      def changed!(msg)
        @changed = true
        log << "  #{msg}"
      end

      def changed?
        !!@changed
      end

    end
  end
end
