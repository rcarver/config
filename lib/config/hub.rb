module Config
  class Hub

    def self.from_file(path)
      content = File.read(path)
      from_string(content, path.to_s, 1)
    end

    def self.from_string(string, _file=nil, _line=nil)
      dsl = Config::DSL::HubDSL.new
      if _file && _line
        dsl.instance_eval(string, _file, _line)
      else
        dsl.instance_eval(string)
      end
      hub = self.new
      hub.project_config = dsl[:project_config]
      hub.data_config = dsl[:data_config]
      hub
    end

    # Get/Set the project Config::Core::GitConfig.
    attr_accessor :project_config

    # Get/Set the data Config::Core::GitConfig.
    attr_accessor :data_config

  end
end
