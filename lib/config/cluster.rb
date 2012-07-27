module Config
  class Cluster

    def self.from_string(name, string, _file, _line = 1)
      dsl = Config::DSL::ClusterDSL.new
      dsl.instance_eval(string, _file, _line)
      cluster = self.new(name)
      cluster.configuration = dsl._get_configuration
      cluster
    end

    def initialize(name)
      @name = name
      @configuration = Config::Configuration.new
    end

    attr :name
    attr_accessor :configuration

    def to_s
      "#{name} cluster"
    end

  end
end
