module Config
  module Core
    module Changeable

      def changed!(msg)
        @changed = true
        log << "  [#{to_s}] #{msg}"
      end

      def changed?
        !!@changed
      end

    end
  end
end
