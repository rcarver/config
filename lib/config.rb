require 'active_support'
require 'active_support/inflector'
require 'json'
require 'pathname'

require 'config/version'

require 'config/core/loggable'

require 'config/core/accumulation'
require 'config/core/attributes'
require 'config/core/changeable'
require 'config/core/conflict_error'
require 'config/core/executable'
require 'config/core/executor'
require 'config/core/facts'
require 'config/core/file'
require 'config/core/git_config'
require 'config/core/git_repo'
require 'config/core/marshalable'
require 'config/core/validation_error'
require 'config/core/remotes'
require 'config/core/ssh_config'

require 'config/patterns'
require 'config/log'

require 'config/pattern'
require 'config/blueprint'
require 'config/cluster'
require 'config/configuration'
require 'config/database'
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
    Config::Project.new(project_loader, database, nodes)
  end

  # Internal: The directory where system-installed projects live.
  #
  # Returns a Pathname.
  def self.system_dir
    @system_dir ||= Pathname.new("/etc/config")
  end

  # Internal: Change the directory where system-installed projects live.
  #
  # dir - String or Pathname.
  #
  # Returns nothing.
  def self.system_dir=(dir)
    @system_dir = Pathname.new(dir)
  end

  # Internal: The directory where the current project lives.
  #
  # Returns a Pathname.
  def self.project_dir
    if system_dir.exist?
      system_dir + "project"
    else
      Pathname.pwd
    end
  end

  # Internal: The directory where the current private data lives.
  #
  # Returns a Pathname.
  def self.private_data_dir
    if system_dir.exist?
      system_dir
    else
      Pathname.pwd + ".data"
    end
  end

  # Internal: Get the project loader.
  #
  # Returns a Config::ProjectLoader.
  def self.project_loader
    Config::ProjectLoader.new(project_dir)
  end

  # Internal: Get the project data.
  #
  # Returns a Config::PrivateData.
  def self.private_data
    Config::PrivateData.new(private_data_dir)
  end

  # Internal: Get the project database.
  #
  # Returns a Config::Database.
  def self.database
    repo = private_data.database_git_repo
    Config::Database.new(repo.path, repo)
  end

  # Internal: Get the project nodes.
  #
  # Returns a Config::Nodes.
  def self.nodes
    Config::Nodes.new(database)
  end

end
