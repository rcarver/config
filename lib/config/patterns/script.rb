module Config
  module Patterns
    class Script < Config::Pattern

      desc "Name of the script"
      key :name

      desc "The code"
      attr :code

      desc "The reverse code"
      attr :reverse, nil

      def describe
        "Script #{name.inspect}"
      end

      def create
        run(code)
      end

      def destroy
        if reverse
          run(reverse)
        else
          log << "No reverse code was given"
        end
      end

    protected

      def run(code)
        bundler_environment = remove_bundler_from_environment
        out, err, status = Open3.capture3(code)
        add_to_environment(bundler_environment)

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

      def remove_bundler_from_environment
        environment = {}
        ['BUNDLE_GEMFILE', 'BUNDLE_BIN_PATH', 'GEM_HOME', 'GEM_PATH'].each do |variable|
          environment[variable] = ENV.delete(variable)
        end

        environment
      end

      def add_to_environment(environment)
        environment.each do |key, value|
          ENV[key] = value
        end
      end

    end
  end
end

