module Config
  class Pattern
    include Config::Core::Attributes
    include Config::Core::Executable
    include Config::Core::Changeable
    include Config::Core::Loggable
    include Config::Core::Marshalable
    include Config::Patterns

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
    def validate
      # noop
    end

    # Public
    def prepare
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

      # Instantiate the pattern.
      pattern = pattern_class.new

      # Configure and accumulate the pattern.
      pattern.accumulation = self.accumulation
      pattern.parent = self
      accumulation << pattern

      # Log the pattern addition.
      log << "+ #{pattern_class}"

      # Indent two to align with the conclusion below. This allows log output
      # triggered by the pattern setup to fall within this block.
      log.indent do
        yield pattern if block_given?
      end

      # Show the final pattern.
      log << "  #{pattern}"

      # Indent and call. This triggers a recursive addition of the entire
      # pattern branch.
      log.indent do
        pattern.call
      end

      nil
    end

    # Internal.
    attr_writer :accumulation

    def accumulation
      @accumulation ||= []
    end

    def validation_errors
      @validation_errors ||= []
    end

    def error_messages
      errors = []
      errors.concat attribute_errors
      errors.concat validation_errors
      errors
    end

    def inspect
      attrs = JSON.generate(attributes)
      "<#{self.class.name} #{attrs}>"
    end

    def get_binding
      binding
    end

  end
end
