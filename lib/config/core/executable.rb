module Config
  module Core
    module Executable

      def run_mode
        @run_mode ||= :create
      end

      def run_mode=(mode)
        @run_mode = mode
      end

      def execute
        case run_mode
        when :create  then create
        when :destroy then destroy
        when :skip    # noop
        else raise ArgumentError, "Unknown run_mode #{run_mode.inspect}"
        end
      end

    end
  end
end
