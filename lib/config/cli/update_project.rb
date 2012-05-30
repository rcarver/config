module Config
  module CLI
    class UpdateProject < Config::CLI::Base

      def usage
        "#{name}"
      end

      def execute
        exec <<-STR
#!/bin/bash
set -e
#{project.update_project_script}
bundle install
        STR
      end

    end
  end
end





