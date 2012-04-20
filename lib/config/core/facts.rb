require 'ohai'
module Config
  module Core
    class Facts
      include Config::Core::Loggable

      # Public: Get facts about the execution environment. This uses
      # ohai underheath.
      #
      # Returns a Config::Core::Facts.
      def self.invent
        ohai = Ohai::System.new
        ohai.all_plugins
        new ohai.data
      end

      def initialize(data)
        @data = data
        @chain = FactChain.new([], @data)
      end

      def to_s
        "[Facts: #{@data.keys.sort.join(',')}]"
      end

      def [](key)
        @data[key.to_s]
      end

      def method_missing(message, *args, &block)
        @chain.public_send(message, *args, &block)
      end

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
          when Hash, Mash
            self.class.new(@chain + [message], value)
          else
            value
          end
        end
      end

    end
  end
end
