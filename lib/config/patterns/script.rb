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
          log << "SKIPPED (not_if exited with zero status)"
        else
          log << "RUNNING (not_if exited with status #{status.exitstatus})"
        end

        not successful
      end

      def run(code)
        status = nil

        Open3.popen3(code) do |stdin, stdout, stderr, thread|

          until stdout.eof? && stderr.eof?
            out = stdout.gets
            err = stderr.gets
            log << log.colorize("[o] ", :cyan)    + out if out
            log << log.colorize("[e] ", :magenta) + err if err
          end

          status = thread.value
        end

        color = status.exitstatus == 0 ? :cyan : :red
        log << log.colorize("[?] ", color) + status.exitstatus.to_s

        unless status.exitstatus == 0
          raise Config::Error, "#{self} returned status #{status.exitstatus}"
        end
      end

    end
  end
end

