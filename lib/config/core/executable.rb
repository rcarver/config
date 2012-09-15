module Config
  module Core
    # This module implements the runtime concerns for Config::Pattern.
    #
    # * How the pattern should be executed (the run mode).
    # * Whether it should be skipped (if any parent is skipped).
    # * Whether it should not cause any changes (noop mode).
    module Executable

      # Public: Execute this pattern. The result of this method depends
      # on the value of `run_mode`, `skip_parent?` and `noop?`
      #
      # Returns nothing.
      def execute
        if skip_parent?
          prefix = "SKIP "
          skip = true
        end
        case run_mode
        when :create
          log << log.colorize("#{prefix}+ #{self}", :green)
          log.indent do
            prepare unless skip
            create  unless skip or noop?
          end
        when :destroy
          log << log.colorize("#{prefix}- #{self}", :red)
          log.indent do
            prepare unless skip
            destroy unless skip or noop?
          end
        when :skip
          log << log.colorize("SKIP #{self}", :blue)
        else
          raise "Unknown run_mode #{run_mode.inspect}"
        end
      end

      # Public: Determine if this pattern is running in create mode.
      #
      # Returns a Boolean.
      def create?
        run_mode == :create
      end

      # Public: Determine if this pattern is running in destroy mode.
      #
      # Returns a Boolean.
      def destroy?
        run_mode == :destroy
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
