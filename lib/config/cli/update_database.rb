module Config
  module CLI
    class UpdateDatabase < Config::CLI::Base

      desc <<-STR
Update the database to the latest version.
      STR

      attr_accessor :fqn

      def usage
        "#{name} [<fqn>]"
      end

      def parse(options, argv, env)
        @fqn = argv.shift
      end

      def execute
        settings = case 
        when @fqn then project.node_settings(@fqn)
        else project.base_settings
        end

        remotes = settings.remotes
        project_data = self.project_data

        blueprint do
          add Config::Meta::CloneDatabase do |p|
            p.path = project_data.database_git_repo.path
            p.url = remotes.database_git_config.url
          end
        end

        project.update_database
      end

    end
  end
end




