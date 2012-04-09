module Config
  class Pattern
    include Config::Core::Attributes
    include Config::Core::Executable
    include Config::Core::Changeable

    def initialize(accumulation)
      @accumulation = accumulation
    end

    # Public
    def to_s
      attrs = key_attributes.map { |k, v| "#{k}:#{v}" }.join(",")
      "#{self.class.name} #{attrs}"
    end

    # Public
    def call
      raise NotImplementedError
    end

    # Public
    def create
      # noop
    end

    # Public
    def destroy
      # noop
    end

    # Public
    def add(pattern_class, &block)
      @accumulation.current = self
      @accumulation.add(pattern_class, &block)
      nil
    end

    # Internal
    attr_accessor :parent

    # Internal
    def parents
      parents = []
      ref = self
      while parent = ref.parent
        ref = parent
        parents << parent
      end
      parents
    end

  end
end
