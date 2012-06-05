module Config
  module CLI
    class UpdateProject < Config::CLI::Base

      desc <<-STR
Update to the latest version of the project. Running this command pulls
the latest version from the origin and updates dependencies.

The command will abort immediately if the current working directory is
not cleanly checked in, therefore it is always safe to run.
      STR

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





