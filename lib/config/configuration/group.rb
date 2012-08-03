module Config
  module Configuration
    class Group
      include Config::Core::Loggable
      include Config::Configuration::MethodMissing

      def initialize(level_name, name, hash={})
        @level_name = level_name
        @name = name
        @hash = hash
      end

      def [](key)
        if @hash.key?(key)
          value = @hash[key]
          log << "Read #{@name}.#{key} => #{value.inspect}"
          value
        else
          raise UnknownVariable, "#{key.to_s} is not defined in #{self}"
        end
      end

      def defined?(key)
        @hash.key?(key)
      end

      def to_s
        "<Configuration::Group #{@name.inspect} (#{@level_name.inspect})>"
      end

    end
  end
end
