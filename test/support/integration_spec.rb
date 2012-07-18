class IntegrationSpec < UnitSpec

  register_spec_type(self) do |desc|
    desc =~ /filesystem/
  end

  # Change the current directory for the life of a block.
  #
  # Yields.
  #
  # Returns nothing.
  def within(dir, &block)
    Dir.chdir(dir, &block)
  end

  # Execute a shell command.
  #
  # command - String command to run.
  #
  # Returns the stdout + stderr.
  # Raises a RuntimeError if the exit status is not 0.
  def cmd(command)
    o, s = Open3.capture2e(command)
    raise o unless s.exitstatus == 0
    o
  end

  # Create a temporary directory. This directory will exist for the life of
  # the spec.
  #
  # id - Identifier of the tmpdir (default: the default identifier).
  #
  # Returns a Pathname.
  def tmpdir(id=:default)
    @tmpdirs[id] ||= Pathname.new(Dir.mktmpdir).realdirpath
  end

  before do
    @tmpdirs = {}
  end

  after do
    @tmpdirs.values.each { |dir| FileUtils.rm_rf dir.to_s }
  end
end


