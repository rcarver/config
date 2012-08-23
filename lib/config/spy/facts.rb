module Config
  module Spy
    # Spy::Facts is an alternative implementation of Config::Facts that
    # returns fake values for any item accessed.
    #
    # Spies can be used to inspect the execution of a Blueprint or
    # Pattern.
    class Facts

      def initialize
        @root = Value.new([])
      end

      # Internal: Retrieve the chains that have been accessed. Use this
      # to find out what happened.
      #
      # Examples
      #
      #   spy.a
      #   spy.a.b
      #   spy.x.y.z
      #   spy.get_accessed_chains
      #   # => ["a.b", "x.y.z"]
      #
      # Returns an Array of Strings.
      def get_accessed_chains
        @root.get_accessed_chains
      end

      def to_s
        "<Spy Facts>"
      end

      def [](key)
        @root[key]
      end

      # Enables dot syntax.
      def method_missing(message, *args, &block)
        @root[message]
      end

      def ==(other)
        get_accessed_chains == other.get_accessed_chains
      end

      class Value
        include Config::Core::Loggable

        def initialize(chain)
          @chain = chain
          @values = {}
        end

        def get_accessed_chains
          if @values.any?
            @values.values.map { |v| v.get_accessed_chains }.flatten.uniq.sort
          else
            [@chain.join('.')]
          end
        end

        def to_s
          "fake:#{@chain.join('.')}"
        end

        # Behave like a String.
        alias to_str to_s

        def [](key)
          @values[key.to_s] ||= begin
            chain = @chain + [key.to_s]
            value = self.class.new(chain)
            log << "Read #{chain.join('.')} => #{value.to_s.inspect}"
            value
          end
        end

        def method_missing(message, *args, &block)
          self[message]
        end
      end
    end
  end
end
