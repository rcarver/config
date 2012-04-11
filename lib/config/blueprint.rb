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
      root = Config::Pattern.new
      root.accumulation = @accumulation
      root.parent = nil
      root.log = log
      root.instance_eval(&@block)
      @executor.accumulate
      @accumulation
    end

    def validate
      begin
        log << "Validate #{self}"
        @executor.validate!
      rescue Config::Core::ValidationError => e
        log.indent do
          e.errors.each do |msg|
            log << "ERROR #{msg}"
          end
        end
        raise
      end
      begin
        log << "Resolve #{self}"
        @executor.resolve!
      rescue Config::Core::ConflictError => e
        log.indent do
          log << "CONFLICT #{e.message}"
        end
        raise
      end
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
