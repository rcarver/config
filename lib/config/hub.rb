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
      hub.git_project = dsl[:git_project]
      hub.git_data = dsl[:git_data]
      hub
    end

    attr_accessor :git_project
    attr_accessor :git_data

  end
end
