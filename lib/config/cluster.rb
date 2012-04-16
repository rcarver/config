module Config
  class Cluster

    def self.from_file(path)
      name = File.basename(path, ".rb")
      content = File.read(path)
      from_string(name, content, path.to_s, 1)
    end

    def self.from_string(name, string, _file=nil, _line=nil)
      dsl = DSL.new
      if _file && _line
        dsl.instance_eval(string, _file, _line)
      else
        dsl.instance_eval(string)
      end
      self.new(name, dsl.blueprint_vars)
    end

    class DSL

      def initialize
        @blueprint_vars = {}
      end

      attr :blueprint_vars

      def blueprint(name, variables)
        @blueprint_vars[name.to_sym] = Config::Core::Variables.new("Blueprint #{name}", variables)
      end

      def inspect
        "<Cluster>"
      end
    end

    def initialize(name, blueprint_vars)
      @name = name
      @blueprint_vars = blueprint_vars
      @nodes = []
    end

    def to_s
      "#{@name} cluster"
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
