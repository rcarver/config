module Config
  # This class represents global state for your project. This state is
  # configured in the `config.rb` file at the root of your project.
  class Global

    def self.from_string(string, _file, _line = 1)
      global = self.new
      dsl = Config::DSL::ClusterDSL.new(global.configuration)
      dsl.instance_eval(string, _file, _line)
      global
    end

    def initialize
      @configuration = Config::Configuration.new("Global")
    end

    attr_reader :configuration

    def to_s
      "Config"
    end
  end
end
