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
        project_data = project.project_data
        hub = project.hub
        blueprint do
          add Config::Meta::CloneDatabase do |p|
            p.path = project_data.repo_path
            p.url = hub.data_config.url
          end
        end
        project.update_database
      end

    end
  end
end




