module Config
  module Patterns
    # A low level pattern. The Script pattern provides complete control
    # over how a system command is executed. It allows commands to be
    # executed for three different reasons:
    #
    #   1. `code` - Code to execute on the system in order to reach the
    #   desired state. This code should be idempotent itself, or be
    #   idempotent with the addition of "not_if" code. If this code
    #   exits with a non-zero status it is considered an error and the
    #   Config execution will abort.
    #
    #   2. `not_if` - Code to execute in order to determine if `code`
    #   should execute. Use this to check for the state that `code` is
    #   expected to create. For example, if `code` creates a file on
    #   disk, `not_if` should check for the existence of that file. If
    #   `not_if` returns a zero status then `code` will not be executed.
    #   Any other status will result in `code` being run.
    #
    #   3. `reverse` - Code to execute in order to reverse the effects
    #   of `code`. When the pattern is destroyed, the `reverse` code
    #   will be executed. If the reverse code exits with a non-zero
    #   status it is considered an error and the Config execution will
    #   abort.
    #
    # No `code_exec` interpreter is defined by default. It is
    # recommended to use a higher level pattern such as
    # `Config::Patterns::Bash` for shell scripts, or a language-specific
    # pattern for executing other types of code.
    #
    # Note that the interpeter set via `code_exec` will also determine
    # the intepreter for `not_if_exec` and `reverse_exec` if they are
    # not explicitly set.
    #
    # Examples
    #
    #   # This script manages an empty file at /tmp/file by running
    #   # bash scripts. To create, check for existence, and delete.
    #   add Config::Pattern::Script do |s|
    #     s.code_exec = "bash"
    #     s.code_args = "-e"
    #     s.code_env = { "FILE_NAME" => "file" }
    #     s.code = <<-STR.dent
    #       cd /tmp
    #       touch $FILE_NAME
    #     STR
    #     s.not_if = "test -f /tmp/$FILE_NAME"
    #     s.reverse = "rm /tmp/$FILE_NAME"
    #   end
    #
    class Script < Config::Pattern

      desc "Name of the script"
      key :name

      # Execute code

      desc "The code to execute"
      attr :code

      desc "The command used to execute code"
      attr :code_exec

      desc "Arguments passed to code_exec"
      attr :code_args, nil

      desc "ENV passed to code_exec"
      attr :code_env, nil

      # Execute reverse code

      desc "The reverse code to execute"
      attr :reverse, nil

      desc "The command used to execute reverse"
      attr :reverse_exec, nil

      desc "Arguments passed to reverse_exec"
      attr :reverse_args, nil

      desc "ENV passed to reverse_exec"
      attr :reverse_env, nil

      # Execute to determine if `code` should execute.

      desc "Code to determine if this script should be run"
      attr :not_if, nil

      desc "The command used to execute not_if"
      attr :not_if_exec, nil

      desc "Arguments passed to not_if_exec"
      attr :not_if_args, nil

      desc "ENV passed to not_if_exec"
      attr :not_if_env, nil


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
          log << log.colorize(">>> #{code_shell_command}", :cyan)
          log << sanitize_for_logging(code)
          log << log.colorize("<<<", :cyan)
        end
      end

      def create
        if should_run?
          execute!(code_shell_command)
        end
      end

      def destroy
        if reverse
          execute!(reverse_shell_command)
        end
      end

    protected

      def code_shell_command
        Config::Core::ShellCommand.new do |s|
          s.command = code_exec
          s.args = code_args
          s.stdin_data = code
          s.on_stdout = on_stdout
          s.on_stderr = on_stderr
        end
      end

      def reverse_shell_command
        Config::Core::ShellCommand.new do |s|
          if reverse_exec
            s.command = reverse_exec
            s.args = reverse_args
            s.env = reverse_env
          else
            s.command = code_exec
            s.args = reverse_args || code_args
            s.env = reverse_env || code_env
          end
          s.stdin_data = reverse
          s.on_stdout = on_stdout
          s.on_stderr = on_stderr
        end
      end

      def not_if_shell_command
        Config::Core::ShellCommand.new do |s|
          if not_if_exec
            s.command = not_if_exec
            s.args = not_if_args
            s.env = not_if_env
          else
            s.command = code_exec
            s.args = not_if_args || code_args
            s.env = not_if_env || code_env
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

