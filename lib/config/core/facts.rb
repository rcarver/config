require 'ohai'
module Config
  module Core
    class Facts
      include Config::Core::Loggable

      # Public: Get facts about the execution environment. This uses
      # ohai underheath to scan the current system.
      #
      # Returns a Config::Core::Facts.
      def self.invent
        ohai = Ohai::System.new
        ohai.all_plugins
        new ohai.data.to_hash
      end

      # Reconstruct facts from JSON data.
      #
      # Returns a Config::Core::Facts.
      def self.from_json(json)
        new(json)
      end

      def initialize(data)
        raise ArgumentError, "Expected a Hash, got #{data.class}" unless data.class == Hash
        @data = data
        @chain = FactChain.new([], @data)
      end

      def to_s
        "[Facts: #{@data.keys.sort.join(',')}]"
      end

      def as_json
        @data.to_hash
      end

      # Access facts by name.
      def [](key)
        @data[key.to_s]
      end

      # Provides dot syntax.
      def method_missing(message, *args, &block)
        @chain.public_send(message, *args, &block)
      end

      attr_reader :data

      def eql?(other)
        data == other.data
      end

      alias == eql?

      class FactChain

        def initialize(chain, data)
          @chain = chain
          @key = @chain.join('.')
          @data = data
        end

        def to_s
          "[FactChain #{@key} => #{@data.keys.sort.join(',')}]"
        end

        def method_missing(message, *args, &block)
          raise ArgumentError, "Arguments are not allowed" if args.any?

          value = @data[message.to_s]

          case value
          when Hash
            self.class.new(@chain + [message], value)
          else
            value
          end
        end
      end

    end
  end
end
