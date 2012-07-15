module Config
  class ProjectSettings

    # These are the configuration sets that are expected to be defined.
    # The definition of any set is optional, though it may result in
    # missing data at another layer. The keys for each set are also 
    # optional.
    #
    # TODO: how to document the sets and keys used here?
    #
    # Domain
    PROJECT_HOSTNAME    = :project_hostname
    #
    # Remotes
    PROJECT_GIT_CONFIG  = :project_git_config
    DATABASE_GIT_CONFIG = :database_git_config
    SSH_CONFIGS         = :ssh_configs

    def initialize(configuration)
      @configuration = configuration
    end

    def domain
      _key(_set(PROJECT_HOSTNAME), :domain)
    end

    def remotes
      remotes = Config::Core::Remotes.new
      remotes.project_git_config = build_git_config(PROJECT_GIT_CONFIG)
      remotes.database_git_config = build_git_config(DATABASE_GIT_CONFIG)
      (_set(SSH_CONFIGS) || []).each do |set|
        remotes.standalone_ssh_configs << build_ssh_config(set)
      end
      remotes
    end

  protected

    # Safe set reader.
    def _set(name)
      @configuration[name] if @configuration.defined?(name)
    end

    # Safe key reader.
    def _key(set, key)
      set[key] if set && set.defined?(key)
    end

    # Used by get_remotes.
    def build_git_config(name)
      return unless _set(name)
      git_config = Config::Core::GitConfig.new
      git_config.url = _key(_set(name), :url)
      build_ssh_config(_set(name), git_config.ssh_config)
      git_config
    end

    # Used by get_remotes.
    def build_ssh_config(set, ssh_config = nil)
      ssh_config ||= Config::Core::SSHConfig.new
      ssh_config.host =     _key(set, :host)
      ssh_config.user =     _key(set, :user)
      ssh_config.port =     _key(set, :port)
      ssh_config.hostname = _key(set, :hostname)
      ssh_config.ssh_key =  _key(set, :ssh_key)
      ssh_config
    end

  end
end
