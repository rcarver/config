module Config
  module Core
    class Configuration

      DuplicateGroup = Class.new(StandardError)
      UnknownGroup = Class.new(StandardError)
      UnknownVariable = Class.new(StandardError)

      def initialize
        @groups = {}
      end

      def to_s
        "<Configuration>"
      end

      def set_group(group_name, hash)
        if @groups[group_name.to_sym]
          raise DuplicateGroup, "#{group_name} has already been defined"
        end
        @groups[group_name.to_sym] = Group.new(group_name.to_sym, hash)
      end

      def method_missing(message, *args, &block)
        raise ArgumentError, "arguments are not allowed: #{message}(#{args.inspect})" if args.any?
        @groups[message] or raise UnknownGroup, "#{message} group is not defined"
      end

      class Group
        include Loggable

        def initialize(name, hash={})
          @name = name
          @hash = hash
        end

        def to_s
          "[Configure #{@name.inspect}]"
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

        def method_missing(message, *args, &block)
          raise ArgumentError, "arguments are not allowed: #{message}(#{args.inspect})" if args.any?
          self[message]
        end
      end

    end
  end
end
