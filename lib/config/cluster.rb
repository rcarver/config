module Config
  class Cluster

    def self.from_string(name, string, _file, _line = 1)
      cluster = self.new(name)
      dsl = Config::DSL::ClusterDSL.new(cluster.configuration)
      dsl.instance_eval(string, _file, _line)
      cluster
    end

    def initialize(name)
      @name = name
      @configuration = Config::Configuration.new(to_s)
    end

    attr :name
    attr_accessor :configuration

    def to_s
      "Cluster[#{name}]"
    end

  end
end
