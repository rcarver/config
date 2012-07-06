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
require 'config/core/git_config'
require 'config/core/git_repo'
require 'config/core/marshalable'
require 'config/core/validation_error'
require 'config/core/facts'
require 'config/core/ssh_config'

require 'config/data/file'
require 'config/data/git_database'

require 'config/patterns'
require 'config/log'

require 'config/pattern'
require 'config/blueprint'
require 'config/cluster'
require 'config/configuration'
require 'config/node'
require 'config/nodes'
require 'config/project'
require 'config/project_data'
require 'config/project_loader'

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

  # Public: Instantiate a project, using the best guess as to its
  # location on disk.
  #
  # Returns a Config::Project.
  def self.project
    root = Pathname.new("/etc/config")
    if root.exist?
      Config::Project.new(root + "project", root)
    else
      Config::Project.new(Pathname.pwd, Pathname.pwd + ".data")
    end
  end

end
