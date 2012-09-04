module Config
  module Core
    # A wrapper around executing a command on the system. Seamlessly
    # streams the STDOUT and STDERR streams to you.
    class ShellCommand

      # Internal: Initialize a new command.
      #
      # Yields the object for configuration.
      #
      def initialize
        @command = nil
        @args = nil
        @on_stdout = -> line { }
        @on_stderr = -> line { }
        @status = nil
        yield self if block_given?
      end

      # String - The command to execute.
      attr_accessor :command

      # String or Array - Arguments to the command.
      attr_accessor :args

      # String - Passed to STDIN of the executed command.
      attr_accessor :stdin_data

      # Block - Handle each line of STDOUT.
      attr_accessor :on_stdout

      # Block - Handle each line of STDERR.
      attr_accessor :on_stderr

      # Returns Process::Status of the last execution.
      attr_reader :status

      # Execute the command.
      def execute
        @status = nil

        Open3.popen3(spawn) do |stdin, stdout, stderr, thread|

          if @stdin_data
            stdin.print @stdin_data
            stdin.close
          end

          threads = [thread]

          threads << Thread.new do
            stream(stdout, @on_stdout)
          end

          threads << Thread.new do
            stream(stderr, @on_stderr)
          end

          threads.each { |t| t.join }
          @status = thread.value
        end

        return nil
      end

      # Returns a Integer the status code of the last execution.
      def exitstatus
        @status.exitstatus
      end

      # Returns a Boolean true if the last execution exited with 0
      # status.
      def success?
        exitstatus == 0
      end

      # Returns a String the command and args that will be executed.
      def to_s
        Array(spawn).join(" ")
      end

    protected

      # Translate `command` and `args` into what Process.spawn expects.
      # http://www.ruby-doc.org/core-1.9.3/Process.html#method-c-spawn
      def spawn
        raise ArgumentError, "No command" if @command.nil?
        parts = [@command]
        case @args
        when NilClass
        when Array  then parts << @args.join(" ")
        when String then parts << @args
        else raise ArgumentError, "Cannot handle args: #{@args.inspect}"
        end
        parts.size == 1 ? parts.first : parts
      end

      # Stream an IO, specifically handling \r line continuations.
      def stream(io, callable)
        buffer = ""
        while char = io.gets(1)
          buffer << char
          if char == "\n" || char == "\r"
            callable.call buffer.dup
            buffer.clear
          end
        end
      end

    end
  end
end
