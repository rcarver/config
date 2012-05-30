class UnitSpec < MiniTest::Spec

  register_spec_type(self) do |desc|
    true
  end

  def execute_pattern(pattern=subject)
    # Accumulate patterns
    accumulation = Config::Core::Accumulation.new
    pattern.accumulation = accumulation

    # Call the pattern under test.
    pattern.call

    # Now execute the result.
    executor = Config::Core::Executor.new(accumulation)
    executor.accumulate
    executor.validate!
    executor.resolve!
    executor.execute
  end

  def log
    Config.log
  end

  def log_string
    log_stream.string
  end

  let(:log_stream) { StringIO.new }

  before do
    Config.log_to log_stream
    Config.log_color false
  end
end
