module Config
  class Blueprint
    include Config::Core::Loggable

    def self.from_file(path)
      name = File.basename(path, ".rb")
      content = File.read(path)
      from_string(name, content, path.to_s, 1)
    end

    def self.from_string(name, string, _file=nil, _line=nil)
      new(name) do
        if _file && _line
          eval string, binding, _file, _line
        else
          eval string, binding
        end
      end
    end

    def initialize(name, &block)
      @name = name
      @block = block
      @accumulation = Config::Core::Accumulation.new
      @executor = Config::Core::Executor.new(@accumulation)
    end

    attr :name

    def to_s
      "Blueprint #{@name}"
    end

    attr_accessor :facts
    attr_accessor :configuration
    attr_accessor :previous_accumulation

    def accumulate
      return @accumulation if @accumulated
      @accumulated = true

      root = Config::DSL::BlueprintDSL.new
      root._set_facts(facts)
      root._set_configuration(configuration)
      root.accumulation = @accumulation
      root.parent = nil

      log << "Accumulate #{self}"
      log.indent do
        root.instance_eval(&@block)
        @executor.accumulate
      end

      @accumulation
    end

    def noop!
      accumulate.each do |pattern|
        pattern.noop!
      end
    end

    def validate
      return if @validated
      @validated = true
      accumulate

      begin
        log << "Validate #{self}"
        log.indent do
          @executor.validate!
        end
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
        log.indent do
          @executor.resolve!
        end
      rescue Config::Core::ConflictError => e
        log.indent do
          log << "CONFLICT #{e.message}"
        end
        raise
      end

      return nil
    end

    def execute
      return if @executed
      @executed = true
      validate

      log << "Execute #{self}"
      log.indent do
        @executor.execute(@previous_accumulation)
      end

      return nil
    end

  end
end
