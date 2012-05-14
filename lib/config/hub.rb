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
      hub.git_project_url = dsl[:git_project]
      hub.git_data_url = dsl[:git_data]
      hub
    end

    # Get/Set the project's git clone url.
    attr_accessor :git_project_url

    # Get/Set the project data's git clone url.
    attr_accessor :git_data_url

    # TODO: allow ssh config to be specified for project and data?
    # TODO: allow forms other than `user@host:path`?

    def git_ssh_host
      git_project_url[/@(.*?):/, 1] if git_project_url
    end

    def git_ssh_port
      "22" if git_project_url
    end

    def git_ssh_user
      git_project_url[/(^.*)@/, 1] if git_project_url
    end

  end
end
