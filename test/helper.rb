require 'minitest/spec'
require 'minitest/autorun'

require 'tmpdir'
require 'fileutils'
require 'pathname'

require 'config'

class ConfigSpec < MiniTest::Spec

  register_spec_type(self) { |desc| true }

  def log_clear(loggable=subject)
    subject.log.stream = StringIO.new
  end

  def log_string(loggable=subject)
    subject.log.stream.string
  end

  def log_lines(loggable=subject)
    log_string.split("\n")
  end
end

class FilesystemSpec < ConfigSpec

  register_spec_type(self) { |desc| desc =~ /filesystem/ }

  # Create a temporary directory. This directory will exist for the life of
  # the spec.
  #
  # id - Identifier of the tmpdir (default: the default identifier).
  #
  # Returns a Pathname.
  def tmpdir(id=:default)
    @tmpdirs[id] ||= Pathname.new(Dir.mktmpdir)
  end

  before do
    @tmpdirs = {}
  end

  after do
    @tmpdirs.values.each { |dir| FileUtils.rm_rf dir.to_s }
  end

end

