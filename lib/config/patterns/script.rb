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

      desc "The reverse code to execute"
      attr :reverse, nil

      desc "The code or lambda to evaluate to determine if this script should be run"
      attr :not_if, nil

      def describe
        "Script #{name.inspect}"
      end

      def prepare
        if destroy?
          if reverse
            log << log.colorize(">>>", :cyan)
            log << sanitize_for_logging(reverse)
            log << log.colorize("<<<", :cyan)
          else
            log << "No reverse code was given"
          end
        else
          if not_if
            log << log.colorize("not_if", :cyan)
            log << sanitize_for_logging(not_if)
          end
          log << log.colorize(">>>", :cyan)
          log << sanitize_for_logging(code)
          log << log.colorize("<<<", :cyan)
        end
      end

      def create
        run(code) if should_run?
      end

      def destroy
        if reverse
          run(reverse)
        end
      end

    protected

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

        out, err, status = Open3.capture3(not_if)
        successful = status.exitstatus == 0

        if successful
          log << log.colorize("SKIPPED (not_if exited with zero status)", :cyan)
        else
          log << log.colorize("RUNNING (not_if exited with status #{status.exitstatus})", :brown)
        end

        not successful
      end

      # Translate `open` and `args` into what Process.spawn expects.
      # http://www.ruby-doc.org/core-1.9.3/Process.html#method-c-spawn
      def command
        parts = [open]
        case args
        when NilClass
        when Array  then parts << args.join(" ")
        when String then parts << args
        else raise ArgumentError, "Cannot handle args: #{args.inspect}"
        end
        parts.size == 1 ? parts.first : parts
      end

      def command_string
        Array(command).join(" ")
      end

      # Run code via an interpreter and log the results.
      # Raises an error if the process does not return 0.
      def run(code)
        status = nil

        Open3.popen3(command) do |stdin, stdout, stderr, thread|
          stdin.print code
          stdin.close

          threads = [thread]

          threads << Thread.new do
            stream(stdout, log.colorize("[o]", :cyan))
          end

          threads << Thread.new do
            stream(stderr, log.colorize("[e]", :white))
          end

          threads.each { |t| t.join }
          status = thread.value
        end

        color = status.exitstatus == 0 ? :cyan : :red
        log << log.colorize("[?] ", color) + status.exitstatus.to_s

        unless status.exitstatus == 0
          raise Config::Error, "#{self} returned status #{status.exitstatus}"
        end
      end

      # Stream an IO, specifically handling \r line continuations.
      def stream(io, prefix)
        buffer = ""
        while char = io.gets(1)
          buffer << char
          if char == "\n" || char == "\r"
            log.verbatim "#{prefix} #{buffer}"
            buffer.clear
          end
        end
      end
    end
  end
end

