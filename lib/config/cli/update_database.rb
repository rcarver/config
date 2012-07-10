module Config
  module CLI
    class UpdateDatabase < Config::CLI::Base

      desc <<-STR
Update the database to the latest version.
      STR

      def usage
        "#{name}"
      end

      def execute
        database = self.project_data.database
        remotes = self.project_data.remotes
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




