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
require 'config/core/marshalable'
require 'config/core/validation_error'

require 'config/patterns'

require 'config/blueprint'
require 'config/pattern'
require 'config/log'

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
  # Returns nothing.
  def self.blueprint(&block)
    blueprint = Config::Blueprint.new('tmp', &block)
    blueprint.execute
  end
end
