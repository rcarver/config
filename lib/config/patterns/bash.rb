module Config
  module Patterns
    class Bash < Config::Pattern

      desc { Config::Patterns::Script[:name].desc }
      key :name

      desc { "Arguments for the bash interpreter" }
      attr :args, ["-e", "-u"]

      desc { "Enviroment for the bash interpreter" }
      attr :env, nil

      desc { Config::Patterns::Script[:code].desc }
      attr :code

      desc { Config::Patterns::Script[:reverse].desc }
      attr :reverse, nil

      desc { Config::Patterns::Script[:not_if].desc }
      attr :not_if, nil

      def describe
        "Bash #{name.inspect}"
      end

      def call
        add Config::Patterns::Script do |s|
          s.name = name
          s.code = code
          s.code_exec = "bash"
          s.code_args = args
          s.code_env = env
          s.reverse = reverse
          s.not_if = not_if
        end
      end

    end
  end
end
