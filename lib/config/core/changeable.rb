module Config
  module Core
    module Changeable

      def changed!(msg)
        change_messages << "#{to_s}: #{msg}"
      end

      def change_messages
        @change_messages ||= []
      end

      def changed?
        change_messages.any?
      end

    end
  end
end
