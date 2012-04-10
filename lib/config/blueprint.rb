module Config
  class Blueprint

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
      @log = []
    end

    attr_reader :log

    def to_s
      "Blueprint #{@name}"
    end

    def accumulate
      root = Config::Pattern.new(@accumulation)
      root.instance_eval(&@block)
      @executor.accumulate
      @accumulation
    end

    def validate
      @executor.validate!
      @executor.resolve!
    end

    def execute
      validate
      log << "[begin] #{to_s}"
      @executor.execute(log)
    end

  end
end
