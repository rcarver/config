module Config
  module Core
    module Changeable

      # An array-like object that occumulates change messages.
      class Changes

        def initialize(&block)
          @block = block
          @changes = []
        end

        # Public: Add a change.
        #
        # msg - A String describing the change.
        #
        # Returns nothing.
        def <<(msg)
          @changes << msg
          @block.call(msg)
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

        def changed?
          @changes.any?
        end

        def to_a
          @changes
        end
      end

      # Public: The list of changes that have occurred. When your
      # Pattern causes a change, track it by appending that a message.
      #
      # Examples
      #
      #   changes << "created a file"
      #
      def changes
        @changes ||= Changes.new do |msg|
          log.indent do
            log << msg
          end
        end
      end

      # Public: Determine if any changes occurred.
      #
      # Returns a Boolean.
      def changed?
        changes.changed?
      end

    end
  end
end
