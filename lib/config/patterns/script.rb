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
      attr :only_if, lambda { true }

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
        evaluate(only_if)
      end

      def evaluate(parameter)
        if parameter.is_a? Proc
          parameter.call
        else
          out, err, status = Open3.capture3(parameter)
          status.exitstatus == 0
        end
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

