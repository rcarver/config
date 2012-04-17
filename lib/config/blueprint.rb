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

    class RootPattern < Config::Pattern

      desc "The current Node"
      attr :node

      desc "The current Cluster"
      attr :cluster

      def to_s
        "<Blueprint>"
      end
      def inspect
        "<Blueprint>"
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

    attr_accessor :node
    attr_accessor :cluster

    def accumulate
      return @accumulation if @accumulated
      @accumulated = true

      root = RootPattern.new
      root.accumulation = @accumulation
      root.node = node
      root.cluster = cluster
      root.parent = nil

      log << "Accumulate #{self}"
      log.indent do
        root.instance_eval(&@block)
        @executor.accumulate
      end

      @accumulation
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

    def execute(previous_accumulation=nil)
      return if @executed
      @executed = true
      validate

      if previous_accumulation
        @executor.previous_accumulation = previous_accumulation
      end

      log << "Execute #{self}"
      log.indent do
        @executor.execute
      end

      return nil
    end

  end
end
