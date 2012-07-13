module Config
  module Core
    class Remotes

      # When no Remotes have been configured, we can gather some useful
      # defaults from existing git repository configurations.
      #
      # project_loader - Config::ProjectLoader.
      # database       - Config::Database.
      #
      # Returns a Config::Core::Remotes.
      def self.default(project_loader, database)
        project_git_config = Config::Core::GitConfig.new
        database_git_config = Config::Core::GitConfig.new

        project_loader.chdir do
          repo = `git config --get remote.origin.url`
          project_git_config.url = repo.chomp unless repo.empty?
        end

        database.chdir do
          repo = `git config --get remote.origin.url`
          database_git_config.url = repo.chomp unless repo.empty?
        end

        if project_git_config.url && !database_git_config.url
          database_git_config.url = project_git_config.url.sub(/\.git/, '-db.git')
        end

        new.tap do |remotes|
          remotes.project_git_config = project_git_config
          remotes.database_git_config = database_git_config
        end
      end

      #
      # Instance
      #

      def initialize
        @project_git_config = nil
        @database_git_config = nil
        @standalone_ssh_configs = []
      end

      attr_accessor :project_git_config
      attr_accessor :database_git_config
      attr_reader :standalone_ssh_configs

      # Get all of the ssh configs, both from git configs
      # and extras.
      #
      # Returns an Array of Config::Core::SSHConfig.
      def ssh_configs
        configs = []
        configs << project_git_config.ssh_config if project_git_config
        configs << database_git_config.ssh_config if database_git_config
        configs.concat @standalone_ssh_configs
        configs.compact
      end

      # Get all of the ssh hosts that we know about.
      #
      # Returns an Array of String.
      def ssh_hostnames
        ssh_configs.map { |c| c.hostname }.uniq.sort
      end

      def dump_yaml
        YAML.dump Config::Core::RemotesSerializer.dump(self)
      end
    end
  end
end
