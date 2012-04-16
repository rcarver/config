module Config
  class Cluster

    def self.from_string(name, string)
      dsl = DSL.new
      dsl.instance_eval(string)
      self.new(dsl.blueprint_vars)
    end

    class DSL

      def initialize
        @blueprint_vars = {}
      end

      attr :blueprint_vars

      def blueprint(name, variables)
        @blueprint_vars[name.to_sym] = Config::Core::Variables.new(variables)
      end
    end

    def initialize(blueprint_vars)
      @blueprint_vars = blueprint_vars
      @nodes = []
    end

    def find_node(options)
      nodes = find_all(options)
      raise AmbiguousNode if nodes.size > 1
      nodes.first
    end
    
    def find_all_nodes(options)
      @nodes.find_all { |node| node_match?(node, options) }
    end

  protected

    def method_missing(message, *args, &block)
      if @blueprint_vars[message]
        raise ArgumentError, "Too many arguments to access blueprint" if args.size > 0
        @blueprint_vars[message]
      else
        super
      end
    end

    def node_match?(node, options)
      options.all? do |pattern, attrs|
        if pattern = node.patterns[pattern]
          attrs.all? do |key, value|
            pattern.attributes[key] == value
          end
        end
      end
    end

  end
end
