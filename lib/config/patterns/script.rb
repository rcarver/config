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

      def create
        run(code) if should_run?
      end

      def destroy
        if reverse
          run(reverse)
        else
          log << "No reverse code was given"
        end
      end

    protected

      def should_run?
        return true unless not_if

        out, err, status = Open3.capture3(not_if)
        successful = status.exitstatus != 0

        log.indent do
          if successful
            log << "RUNNING because '#{not_if}' exited with a non-zero status"
          else
            log << "SKIPPED because '#{not_if}' exited with a successful status"
          end
        end

        successful
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

