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
        configuration = case 
        when @fqn then project.node_settings(@fqn)
        else project.base_settings
        end
        remotes = configuration.remotes
        database = project_data.database
        blueprint do
          add Config::Meta::CloneDatabase do |p|
            p.path = database.path
            p.url = remotes.database_git_config.url
          end
        end
        database.update
      end

    end
  end
end




