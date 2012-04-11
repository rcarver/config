module Config
  module Core
    module Marshalable

      def self.included(base)
        base.class_eval do
          include Dump
          extend  Load
        end
      end

      module Dump
        def _dump(level)
          JSON.generate attributes
        end
      end

      module Load
        def _load(data)
          object = new
          attributes = JSON[data]
          attributes.each do |key, value|
            object.attributes[key.to_sym] = value
          end
          object
        end
      end

    end
  end
end

