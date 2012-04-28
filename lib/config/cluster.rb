module Config
  class Cluster

    def self.from_file(path)
      name = File.basename(path, ".rb")
      content = File.read(path)
      from_string(name, content, path.to_s, 1)
    end

    def self.from_string(name, string, _file=nil, _line=nil)
      dsl = Config::DSL::ClusterDSL.new
      if _file && _line
        dsl.instance_eval(string, _file, _line)
      else
        dsl.instance_eval(string)
      end
      cluster = self.new(name)
      cluster.configuration = dsl._get_configuration
      cluster
    end

    def initialize(name)
      @name = name
      @nodes = []
      @configuration = Config::Core::Configuration.new
    end

    attr :name
    attr_accessor :configuration

    def to_s
      "#{name} cluster"
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
