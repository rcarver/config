module Config
  module Core
    class Remotes

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
