require 'active_support'
require 'active_support/inflector'
require 'json'
require 'pathname'

require 'config/version'

require 'config/core/loggable'

require 'config/core/accumulation'
require 'config/core/attributes'
require 'config/core/changeable'
require 'config/core/configuration'
require 'config/core/conflict_error'
require 'config/core/executable'
require 'config/core/executor'
require 'config/core/marshalable'
require 'config/core/validation_error'
require 'config/core/facts'

require 'config/patterns'
require 'config/log'

require 'config/pattern'
require 'config/blueprint'
require 'config/cluster'
require 'config/node'
require 'config/project'

require 'config/dsl/blueprint_dsl'
require 'config/dsl/cluster_dsl'
require 'config/dsl/node_dsl'

require 'config/meta'

module Config

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

  # Public: Create an execute a Blueprint with a block.
  #
  # name - String name of the blueprint.
  # Returns nothing.
  def self.blueprint(name, &block)
    blueprint = Config::Blueprint.new(name, &block)
    blueprint.execute
  end
end
