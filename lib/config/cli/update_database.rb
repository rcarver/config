module Config
  module CLI
    class UpdateDatabase < Config::CLI::Base

      desc <<-STR.dent
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

        directories = self.directories
        remotes = settings.remotes

        blueprint do
          add Config::Meta::CloneDatabase do |p|
            p.path = directories.database_dir
            p.url = remotes.database_git_config.url
          end
        end

        database.update
      end

    end
  end
end




