module Config
  class Pattern
    include Config::Core::Attributes
    include Config::Core::Executable
    include Config::Core::Changeable
    include Config::Core::Loggable

    def initialize(accumulation)
      @accumulation = accumulation
    end

    def to_s
      "[#{describe}]"
    end

    def describe
      attrs = key_attributes.map { |k, v| "#{k}:#{v.inspect}" }.join(",")
      "#{self.class.name} #{attrs}"
    end

    # Public
    def call
      # noop
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

    def error_messages
      errors = []
      errors.concat attribute_errors
      errors
    end

  end
end
