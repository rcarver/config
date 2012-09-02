module Config
  module Patterns
    class Script < Config::Pattern

      desc "Name of the script"
      key :name

      desc "The code"
      attr :code

      desc "The reverse code"
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
            log << reverse
            log << log.colorize("<<<", :cyan)
          else
            log << "No reverse code was given"
          end
        else
          if not_if
            log << log.colorize("not_if", :cyan)
            log << not_if
          end
          log << log.colorize(">>>", :cyan)
          log << code
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

      def run(code)
        status = nil

        Open3.popen3(code) do |stdin, stdout, stderr, thread|
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

