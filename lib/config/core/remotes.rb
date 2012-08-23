module Config
  module Core
    class Remotes

      def initialize
        @project_git_config = Config::Core::GitConfig.new
        @database_git_config = Config::Core::GitConfig.new
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
        configs << project_git_config if project_git_config.host
        configs << database_git_config if database_git_config.host
        configs.concat @standalone_ssh_configs
        configs.compact
      end

      # Get all of the ssh hosts that we know about.
      #
      # Returns an Array of String.
      def ssh_hostnames
        ssh_configs.map { |c| c.hostname }.compact.uniq.sort
      end

      def dump_yaml
        YAML.dump Config::Core::RemotesSerializer.dump(self)
      end
    end
  end
end
