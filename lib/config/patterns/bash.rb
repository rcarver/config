module Config
  module Patterns
    class Bash < Config::Pattern

      desc { Config::Patterns::Script[:name].desc }
      key :name

      desc { Config::Patterns::Script[:code].desc }
      attr :code

      desc { Config::Patterns::Script[:reverse].desc }
      attr :reverse, nil

      desc { Config::Patterns::Script[:not_if].desc }
      attr :not_if, nil

      desc "Set sensible default options (-e and -u)"
      attr :set_sensible_defaults, true

      def describe
        "Bash #{name.inspect}"
      end

      def call
        add Config::Patterns::Script do |s|
          s.name = name
          s.code = add_sensible_defaults(code)
          s.reverse = add_sensible_defaults(reverse)
          s.not_if = not_if
        end
      end

    protected

      def add_sensible_defaults(script)
        if set_sensible_defaults
          [
            "set -o nounset",
            "set -o errexit",
            script
          ].join("\n")
        else
          script
        end
      end

    end
  end
end
