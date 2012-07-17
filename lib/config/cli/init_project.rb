module Config
  module CLI
    class InitProject < Config::CLI::Base

      desc <<-STR
Generate the template for a new project.
      STR

      def usage
        "#{name}"
      end

      def execute
        default_remotes = remotes_factory.call
        blueprint do
          add Config::Meta::Project do |p|
            p.root = Dir.pwd
            p.project_hostname_domain = "internal.example.com"
            p.project_git_config_url = default_remotes.project_git_config.url
            p.database_git_config_url = default_remotes.database_git_config.url
          end
        end
      end

      def remotes_factory
        @remotes_factory or -> { Config.default_remotes }
      end

      attr_writer :remotes_factory

    end
  end
end

