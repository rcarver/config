module Config
  class Hub

    def self.from_file(path)
      content = File.read(path)
      from_string(content, path.to_s, 1)
    end

    def self.from_string(string, _file=nil, _line=nil)
      dsl = Config::DSL::HubDSL.new
      if _file && _line
        dsl.instance_eval(string, _file, _line)
      else
        dsl.instance_eval(string)
      end
      hub = self.new
      hub.domain = dsl[:domain]
      hub.project_config = dsl[:project_config]
      hub.data_config = dsl[:data_config]
      hub.ssh_configs = dsl[:ssh_configs]
      hub
    end

    def initialize
      @ssh_configs = []
    end

    # Get/Set the node's domain. The node's FQDN is determined by
    # <node.fqn>.<hub.domain>.
    attr_accessor :domain

    # Get/Set the project Config::Core::GitConfig.
    attr_accessor :project_config

    # Get/Set the data Config::Core::GitConfig.
    attr_accessor :data_config

    # Set the ssh configs.
    attr_writer :ssh_configs

    # Get the ssh configs.
    #
    # Returns an Array of Config::Core::SSHConfig.
    def ssh_configs
      configs = []
      configs << project_config.ssh_config if project_config
      configs << data_config.ssh_config if data_config
      configs.concat @ssh_configs
      configs
    end

    # Get all of the ssh hosts that we know about.
    #
    # Returns an Array of String.
    def ssh_hostnames
      ssh_configs.map { |c| c.hostname }.uniq.sort
    end

  end
end
