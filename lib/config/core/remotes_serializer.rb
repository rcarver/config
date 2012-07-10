module Config
  module Core
    # Parses data to and from objects. This structure is defined by the Remotes
    # API so we're not defining it all here rather than distributed amongst the
    # various classes
    class RemotesSerializer

      # Load a remotes from data.
      #
      # data - Hash.
      #
      # Returns Config::Core::Remotes
      def self.load(data)
        remotes = Config::Core::Remotes.new
        return remotes unless data.is_a?(Hash)

        load_git_config(Config::Core::GitConfig.new, data["project_git_config"]) do |cfg|
          remotes.project_git_config = cfg
        end
        load_git_config(Config::Core::GitConfig.new, data["database_git_config"]) do |cfg|
          remotes.database_git_config = cfg
        end
        Array(data["ssh_configs"]).each do |ssh_config_data|
          load_ssh_config(Config::Core::SSHConfig.new, ssh_config_data) do |cfg|
            remotes.standalone_ssh_configs << cfg
          end
        end
        remotes
      end

      # Dump a remotes to data.
      #
      # remotes - Config::Core::Remotes.
      #
      # Returns a Hash.
      def self.dump(remotes)
        data = {}
        data["project_git_config"] = dump_git_config({}, remotes.project_git_config)
        data["database_git_config"] = dump_git_config({}, remotes.database_git_config)
        data["ssh_configs"] = []
        remotes.standalone_ssh_configs.each do |ssh_config|
          data["ssh_configs"] << dump_ssh_config({}, ssh_config)
        end
        data
      end

    protected

      def self.load_git_config(git_config, data)
        if data
          git_config.url = data["url"] if data["url"]
          load_ssh_config(git_config.ssh_config, data)
          yield git_config if block_given?
        end
      end

      def self.load_ssh_config(ssh_config, data)
        if data
          ssh_config.host = data["host"] if data["host"]
          ssh_config.user = data["user"] if data["user"]
          ssh_config.ssh_key = data["ssh_key"] if data["ssh_key"]
          ssh_config.port = data["port"] if data["port"]
          ssh_config.hostname = data["hostname"] if data["hostname"]
          yield ssh_config if block_given?
        end
      end

      def self.dump_git_config(data, git_config)
        if git_config
          data["url"] = git_config.url
          dump_ssh_config(data, git_config.ssh_config)
        end
        clean_hash data
      end

      def self.dump_ssh_config(data, ssh_config)
        if ssh_config
          data["host"] = ssh_config.host
          data["user"] = ssh_config.user
          data["ssh_key"] = ssh_config.ssh_key
          data["port"] = ssh_config.port
          data["hostname"] = ssh_config.hostname
        end
        clean_hash data
      end

      def self.clean_hash(data)
        data.each do |key, value|
          data.delete key if value.nil?
        end
      end
    end
  end
end


