require 'active_support'
require 'active_support/inflector'
require 'json'
require 'levels'
require 'open3'
require 'pathname'

require 'config/version'

require 'config/core_ext/string_dent'

require 'config/core/loggable'

require 'config/core/accumulation'
require 'config/core/attributes'
require 'config/core/changeable'
require 'config/core/conflict_error'
require 'config/core/directories'
require 'config/core/executable'
require 'config/core/executor'
require 'config/core/file'
require 'config/core/git_repo'
require 'config/core/marshalable'
require 'config/core/validation_error'
require 'config/core/remotes'
require 'config/core/shell_command'

require 'config/core/ssh_config'
require 'config/core/git_config'

require 'config/configuration'

require 'config/patterns'
require 'config/log'

require 'config/pattern'
require 'config/blueprint'
require 'config/cluster'
require 'config/cluster_context'
require 'config/database'
require 'config/facts'
require 'config/global'
require 'config/node'
require 'config/nodes'
require 'config/private_data'
require 'config/project'
require 'config/project_loader'
require 'config/project_settings'

require 'config/dsl/blueprint_dsl'
require 'config/dsl/cluster_dsl'
require 'config/dsl/node_dsl'

module Config

  module Bootstrap
    autoload :Access, "config/bootstrap/access"
    autoload :Identity, "config/bootstrap/identity"
    autoload :Project, "config/bootstrap/project"
    autoload :System, "config/bootstrap/system"
  end

  autoload :CLI, "config/cli"

  module Meta
    autoload :Blueprint, "config/meta/blueprint"
    autoload :CloneDatabase, "config/meta/clone_database"
    autoload :Cluster, "config/meta/cluster"
    autoload :Pattern, "config/meta/pattern"
    autoload :PatternTopic, "config/meta/pattern_topic"
    autoload :Project, "config/meta/project"
  end

  module Spy
    autoload :ClusterContext, "config/spy/cluster_context"
    autoload :Configuration, "config/spy/configuration"
    autoload :Facts, "config/spy/facts"
  end

  # Public: This exception may be raised by a Pattern if a problem is
  # found during execution. Doing so will abort the current execution.
  Error = Class.new(StandardError)

  # Public: Get the the global logger.
  #
  # Returns a Config::Log.
  def self.log
    @log ||= Config::Log.new
  end

  # Public: Initialize a new logger using the given stream.
  #
  # stream - An IO object.
  #
  # Returns nothing.
  def self.log_to(stream)
    @log = Config::Log.new(stream)
  end

  # Public: Configure color output.
  #
  # bool - Boolean to enable colored output.
  #
  # Returns nothing.
  def self.log_color(bool)
    log.color = bool
  end

  # Public: Instantiate the current project.
  #
  # Returns a Config::Project.
  def self.project
    Config::Project.new(project_loader, nodes)
  end

  # Internal: Get the project loader.
  #
  # Returns a Config::ProjectLoader.
  def self.project_loader
    Config::ProjectLoader.new(directories.project_dir)
  end

  # Internal: Get the project data.
  #
  # Returns a Config::PrivateData.
  def self.private_data
    Config::PrivateData.new(directories.private_data_dir)
  end

  # Internal: Get the project database.
  #
  # Returns a Config::Database.
  def self.database
    Config::Database.new(directories.database_dir, Config::Core::GitRepo.new(directories.database_dir))
  end

  # Internal: Get the project nodes.
  #
  # Returns a Config::Nodes.
  def self.nodes
    Config::Nodes.new(database)
  end

  # Internal: The directories where config accesses everything.
  #
  # Returns a Config::Core::Directories.
  def self.directories
    @directories ||= Config::Core::Directories.new("/etc/config", Dir.pwd)
  end

  # Internal: Set the directories.
  def self.directories=(directories)
    @directories = directories
  end

  # Internal: When no Remotes have been configured, we can gather some useful
  # defaults from existing git repository configurations.
  #
  # Returns a Config::Core::Remotes.
  def self.default_remotes
    project_git_config = Config::Core::GitConfig.new
    database_git_config = Config::Core::GitConfig.new

    if directories.project_dir.exist?
      Dir.chdir(directories.project_dir) do
        repo = `git config --get remote.origin.url`
        project_git_config.url = repo.chomp unless repo.empty?
      end
    end

    if directories.database_dir.exist?
      Dir.chdir(directories.database_dir) do
        repo = `git config --get remote.origin.url`
        database_git_config.url = repo.chomp unless repo.empty?
      end
    end

    if project_git_config.url && !database_git_config.url
      database_git_config.url = project_git_config.url.sub(/\.git/, '-db.git')
    end

    Config::Core::Remotes.new.tap do |remotes|
      remotes.project_git_config = project_git_config
      remotes.database_git_config = database_git_config
    end
  end

end
