module Config
  module Core
    module Changeable
      # An array-like object that occumulates change messages.
      class Changes

        def initialize
          @changes = []
        end

        # Public: Add a change.
        #
        # msg - A String describing the change.
        #
        # Returns nothing.
        def <<(msg)
          @changes << msg
          nil
        end

        # Public: Determine if a change occurred.
        #
        # msg - The String message.
        #
        # Returns a Boolean.
        def include?(msg)
          @changes.include? msg
        end

        # Public: Determine if no changes have occurred.
        #
        # Returns a Boolean.
        def empty?
          @changes.empty?
        end

        def to_a
          @changes
        end
      end

      # Public: The list of changes that have occurred. When your
      # Pattern causes a change, track it by appending a message.
      #
      # Examples
      #
      #   changes << "created a file"
      #
      def changes
        @changes ||= Changes.new
      end

      # Public: Determine if any changes occurred.
      #
      # Returns a Boolean.
      def changed?
        !changes.empty?
      end

    end
  end
end
