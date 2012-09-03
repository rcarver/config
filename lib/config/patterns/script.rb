module Config
  module Patterns
    class Script < Config::Pattern

      desc "Name of the script"
      key :name

      desc "Command to open"
      attr :open, "sh"

      desc "Arguments passed to the command"
      attr :args, nil

      desc "The code to execute"
      attr :code

      desc "The reverse command to open"
      attr :open_reverse, nil

      desc "Arguments passed to the reverse command"
      attr :args_reverse, nil

      desc "The reverse code to execute"
      attr :reverse, nil

      desc "The not_if command to open"
      attr :open_not_if, nil

      desc "Arguments passed to the not_if command"
      attr :args_not_if, nil

      desc "The sh code to determine if this script should be run"
      attr :not_if, nil

      def describe
        "Script #{name.inspect}"
      end

      def prepare
        if destroy?
          if reverse
            log << log.colorize(">>> #{reverse_shell_command}", :cyan)
            log << sanitize_for_logging(reverse)
            log << log.colorize("<<<", :cyan)
          else
            log << "No reverse code was given"
          end
        else
          if not_if
            log << log.colorize("not_if #{not_if_shell_command}", :cyan)
            log << sanitize_for_logging(not_if)
          end
          log << log.colorize(">>> #{shell_command}", :cyan)
          log << sanitize_for_logging(code)
          log << log.colorize("<<<", :cyan)
        end
      end

      def create
        if should_run?
          execute!(shell_command)
        end
      end

      def destroy
        if reverse
          execute!(reverse_shell_command)
        end
      end

    protected

      def shell_command
        Config::Core::ShellCommand.new do |s|
          s.command = open
          s.args = args
          s.stdin_data = code
          s.on_stdout = on_stdout
          s.on_stderr = on_stderr
        end
      end

      def reverse_shell_command
        Config::Core::ShellCommand.new do |s|
          if open_reverse
            s.command = open_reverse
            s.args = args_reverse
          else
            s.command = open
            s.args = args_reverse || args
          end
          s.stdin_data = reverse
          s.on_stdout = on_stdout
          s.on_stderr = on_stderr
        end
      end

      def not_if_shell_command
        Config::Core::ShellCommand.new do |s|
          if open_not_if
            s.command = open_not_if
            s.args = args_not_if
          else
            s.command = open
            s.args = args_not_if || args
          end
          s.stdin_data = not_if
          s.on_stdout = on_stdout
          s.on_stderr = on_stderr
        end
      end

      # Escape control characters from the code so that they aren't
      # interprted in the log output.
      def sanitize_for_logging(original)
        code = original.dup
        code.gsub!(/\a/, '\a')
        #code.gsub!(/\b/, '\b')
        #code.gsub!(/\c/, '\c')
        code.gsub!(/\f/, '\f')
        #code.gsub!(/\n/, '\n')
        code.gsub!(/\r/, '\r')
        code.gsub!(/\t/, '\t')
        code.gsub!(/\v/, '\v')
        code
      end

      # Determine if the command should run by checking the conditional
      # command.
      def should_run?
        return true if not_if.nil?

        shell = not_if_shell_command
        shell.execute

        if shell.success?
          log << log.colorize("SKIPPED (not_if exited with zero status)", :cyan)
        else
          log << log.colorize("RUNNING (not_if exited with status #{shell.exitstatus})", :brown)
        end

        not shell.success?
      end

      def execute!(shell)
        shell.execute

        color = shell.exitstatus == 0 ? :cyan : :red
        log << log.colorize("[?] ", color) + shell.exitstatus.to_s

        unless shell.success?
          raise Config::Error, "#{self} returned status #{shell.exitstatus}"
        end
      end

      def on_stdout
        -> line { log.verbatim log.colorize("[o]", :cyan) + " " + line }
      end

      def on_stderr
        -> line { log.verbatim log.colorize("[e]", :white) + " " + line }
      end

    end
  end
end

