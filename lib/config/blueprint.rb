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
      #@pattern_class = pattern_class
      @accumulation = Config::Core::Accumulation.new
      @executor = Config::Core::Executor.new(@accumulation)
    end

    def to_s
      "Blueprint #{@name}"
    end

    def call
      root = Config::Pattern.new(@accumulation)
      root.instance_eval(&@block)
      @executor.accumulate
    end

    def execute
      @executor.execute
    end

    # Internal
    attr_reader :accumulation

  end
end
