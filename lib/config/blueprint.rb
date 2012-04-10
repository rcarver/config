module Config
  class Blueprint
    include Config::Core::Loggable

    def self.from_string(name, string)
      new(name) do
        eval string
      end
    end

    def initialize(name, &block)
      @name = name
      @block = block
      @accumulation = Config::Core::Accumulation.new
      @executor = Config::Core::Executor.new(@accumulation)
    end

    def to_s
      "Blueprint #{@name}"
    end

    def accumulate
      log << "Accumulate #{self}"
      @accumulation.log = log
      root = Config::Pattern.new(@accumulation)
      root.instance_eval(&@block)
      @executor.accumulate
      @accumulation
    end

    def validate
      log << "Validate #{self}"
      @executor.validate!
      log << "Resolve #{self}"
      @executor.resolve!
    end

    def execute
      validate
      log << "Execute #{self}"
      log.indent do
        @executor.execute
      end
    end

  end
end
