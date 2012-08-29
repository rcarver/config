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
        log.indent(2) do
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

        log.indent do
          if successful
            log << "SKIPPED because not_if exited with zero status"
          else
            log << "RUNNING because not_if exited with status #{status.exitstatus}"
          end
        end

        not successful
      end

      def run(code)
        out, err, status = Open3.capture3(code)

        log.indent do
          log << "STATUS #{status.exitstatus}"
          if out != ""
            log << "STDOUT"
            log.indent do
              log << out
            end
          end
          if err != ""
            log << "STDERR"
            log.indent do
              log << err
            end
          end
        end

        unless status.exitstatus == 0
          raise Config::Error, "#{self} returned status #{status.exitstatus}"
        end
      end

    end
  end
end

