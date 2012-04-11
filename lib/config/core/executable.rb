module Config
  module Core
    module Executable

      # Public: Execute this pattern. The result of this method depends
      # on the value of `run_mode`, `skip_parent?` and `noop?`
      #
      # Returns nothing.
      def execute
        if skip_parent?
          prefix = "Skip "
          skip = true
        end
        case run_mode
        when :create
          log << "#{prefix}Create #{self}"
          create unless skip or noop?
        when :destroy
          log << "#{prefix}Destroy #{self}"
          destroy unless skip or noop?
        when :skip
          log << "Skip #{self}"
        else
          raise "Unknown run_mode #{run_mode.inspect}"
        end
      end

      #
      # Internal API
      #

      # Internal: Set the run mode.
      #
      # mode - Symbol (:create, :destroy, :skip).
      def run_mode=(mode)
        @run_mode = mode
      end

      # Internal: Get the run mode.
      def run_mode
        @run_mode ||= :create
      end

      # Internal: Set noop. A Pattern in noop mode will not actually
      # execute anything.
      def noop!
        @noop = true
      end

      # Internal: Determine if in noop mode.
      def noop?
        !!@noop
      end

      # Internal: Get the parent executable.
      def parent
        @parent
      end

      # Internal: Set the parent executable.
      def parent=(executable)
        @parent = executable
      end

      # Internal: Get all parents.
      def parents
        parents = []
        ref = self
        while parent = ref.parent
          ref = parent
          parents << parent
        end
        parents
      end

      # Internal: Determine if any of my parents are in skip mode.
      def skip_parent?
        parents.any? { |p| p.run_mode == :skip }
      end

    end
  end
end
