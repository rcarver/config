module Config
  module CLI
    class UpdateDatabase < Config::CLI::Base

      def usage
        "#{name}"
      end

      def execute
        data_dir = project.data_dir
        hub = project.hub
        blueprint do
          add Config::Meta::CloneDatabase do |p|
            p.path = data_dir.repo_path
            p.url = hub.data_config.url
          end
        end
        project.update_database
      end

    end
  end
end




