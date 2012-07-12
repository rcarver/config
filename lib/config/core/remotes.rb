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

      def self.from_configuration(configuration)
        new.tap do |remotes|
          if configuration.project_git_config?
            remotes.project_git_config = load_git_config_from_configuration_group(
              Config::Core::GitConfig.new, configuration.project_git_config
            )
          end
          if configuration.database_git_config?
            remotes.database_git_config = load_git_config_from_configuration_group(
              Config::Core::GitConfig.new, configuration.database_git_config
            )
          end
          if configuration.ssh_configs?
            configuration.ssh_configs.each_key do |key|
              remotes.standalone_ssh_configs << load_ssh_config_from_configuration_group(
                Config::Core::SSHConfig.new, configuration.ssh_configs[key]
              )
            end
          end
        end
      end

      def self.load_git_config_from_configuration_group(git_config, group)
        git_config.url = group.url if group.url?
        ssh_config.host = group.host if group.host?
        ssh_config.user = group.user if group.user?
        ssh_config.port = group.port if group.port?
        ssh_config.hostname = group.hostname if group.hostname?
        ssh_config.ssh_key = group.ssh_key if group.ssh_key?
        git_config
      end

      def self.load_ssh_config_from_configuration_group(ssh_config, data)
        ssh_config.host = data[:host]
        ssh_config.user = data[:user]
        ssh_config.port = data[:port]
        ssh_config.hostname = data[:hostname]
        ssh_config.ssh_key = data[:ssh_key]
        ssh_config
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
