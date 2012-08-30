module Config
  module Core
    # This module implements the attributes concerns for
    # Config::Pattern.
    #
    # * Class methods for defining and documenting attributes.
    # * Instance methods for reading the keys and values of attributes.
    # * Validation of attribute definitions and attribute values.
    # * Comparators to compare one pattern to another in order to
    #   determine equality or conflict.
    module Attributes

      def self.included(base)
        base.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods

        # Public: Describe a key or attr. The description is applied to
        # the next key or attr to be defined.
        #
        # msg    - String message.
        # &block - Block to evaluate for the message.
        #
        # Returns nothing.
        # Raises an ArgumentError if both a String and Block are given.
        def desc(msg = nil, &block)
          raise ArgumentError, "Pass only a String or Block" if msg && block
          @_current_desc = msg || block
        end

        # Public: Define a key attribute.
        #
        # name          - Symbol name of the attribute.
        # default_value - Default value of attribute (default:
        #                 undefined)
        #
        # Returns nothing.
        def key(name, default_value=:undefined)
          key_attrs[name] = Attr.new(name, default_value, @_current_desc)
          @_current_desc = nil
          _define_attr(name)
        end

        # Public: Define an attribute.
        #
        # name          - Symbol name of the attribute.
        # default_value - Default value of attribute (default:
        #                 undefined)
        #
        # Returns nothing.
        def attr(name, default_value=:undefined)
          other_attrs[name] = Attr.new(name, default_value, @_current_desc)
          @_current_desc = nil
          _define_attr(name)
        end

        # Public: Get an attribute definition.
        #
        # Returns a Config::Attributes::ClassMethods::Attr.
        def [](name)
          all_attrs[name]
        end

        class Attr < Struct.new(:name, :default_value, :_description)

          def description
            if _description.respond_to?(:call)
              self._description = _description.call
            end
            _description
          end

          alias_method :desc, :description

          # Internal: Check the validity of this attribute.
          #
          # value - Anything.
          #
          # Returns an Array of String.
          def error_messages(value)
            errors = []
            if description.nil?
              errors << "missing description for #{name.inspect}"
            end
            if value.nil? && default_value == :undefined
              errors << "missing value for #{name.inspect} (#{description})"
            end
            if value.nil? && default_value != nil && default_value != :undefined
              errors << "missing value for #{name.inspect} - default: #{default_value.inspect} (#{description})"
            end
            if value.is_a?(String) && value.strip == ""
              errors << "#{value.inspect} is an invalid value for #{name.inspect} (#{description})"
            end
            errors
          end

          def initial_value
            default_value == :undefined ? nil : default_value
          end
        end

        # Internal: A Hash of key attributes.
        def key_attrs
          @key_attrs ||= {}
        end

        # Internal: A Hash of non-key attributes.
        def other_attrs
          @other_attrs ||= {}
        end

        # Internal: A Hash of all attributes.
        def all_attrs
          key_attrs.merge(other_attrs)
        end

      protected

        def _define_attr(name)
          define_method name do
            self.attributes[name]
          end
          define_method "#{name}=" do |value|
            self.attributes[name] = value
          end
        end
      end

      #
      # Instance Methods
      #

      # Public: All attributes.
      #
      # Returns a Hash.
      def attributes
        @attributes ||= begin
           attrs = {}
           self.class.key_attrs.values.each { |a| attrs[a.name] = a.initial_value }
           self.class.other_attrs.values.each { |a| attrs[a.name] = a.initial_value }
           attrs
        end
      end

      # Public: Key attributes.
      #
      # Returns a Hash.
      def key_attributes
        attrs = {}
        self.class.key_attrs.values.each { |a| attrs[a.name] = attributes[a.name] }
        attrs
      end

      # Public: Non-Key attributes.
      #
      # Returns a Hash.
      def other_attributes
        attrs = {}
        self.class.other_attrs.values.each { |a| attrs[a.name] = attributes[a.name] }
        attrs
      end

      # Public: Determine if all attributes have valid values.
      #
      # Returns a Boolean.
      def valid_attributes?
        attribute_errors.empty?
      end

      # Public: Get a description of the invalid attributes.
      #
      # Returns an Array of Strings.
      def attribute_errors
        errors = []
        self.class.all_attrs.values.each do |attr|
          attr.error_messages(attributes[attr.name]).each do |message|
            errors << "[#{to_s}] #{message}"
          end
        end
        errors
      end

      # Public: Determine if all attributes are equal.
      #
      # other - Object.
      #
      # Returns a Boolean
      def ==(other)
        return false unless self.class == other.class
        self.attributes == other.attributes
      end

      # Public: Determine if key attributes are equal.
      #
      # other - Object.
      #
      # Returns a Boolean.
      def eql?(other)
        return false unless self.class == other.class
        self.key_attributes == other.key_attributes
      end

      # Public: Conflict is true if the key attributes are equal
      # but the other attributes are not. (eql? is true and == is
      # false).
      #
      # Returns a Boolean.
      def conflict?(other)
        return false unless self.class == other.class
        self.eql?(other) && self != other
      end

      # Public: Objects hash according to their key attributes only.
      #
      # Returns an Integer.
      def hash
        self.class.hash ^ key_attributes.hash
      end
    end
  end
end
