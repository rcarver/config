module Config
  class Global

    def self.from_string(string, _file, _line = 1)
      dsl = Config::DSL::ClusterDSL.new
      dsl.instance_eval(string, _file, _line)
      self.new(dsl._get_configuration)
    end

    def initialize(configuration = nil)
      @configuration = configuration || Config::Configuration.new
    end

    attr_reader :configuration

    def to_s
      "Config"
    end
  end
end
