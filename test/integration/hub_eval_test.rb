require 'helper'

describe Config::Hub do

  describe ".from_string" do

    it "works with a simple config" do

      hub = Config::Hub.from_string <<-STR
        domain "internal.example.com"
        project_repo "git@github.com:rcarver/config-example.git"
        data_repo    "git@github.com:rcarver/config-example-data.git"
      STR

      hub.domain.must_equal "internal.example.com"

      hub.project_config.url.must_equal "git@github.com:rcarver/config-example.git"
      hub.project_config.ssh_config.host.must_equal "github.com"
      hub.project_config.ssh_config.user.must_equal "git"
      hub.project_config.ssh_config.ssh_key.must_equal "default"

      hub.data_config.url.must_equal "git@github.com:rcarver/config-example-data.git"
      hub.data_config.ssh_config.host.must_equal "github.com"
      hub.data_config.ssh_config.user.must_equal "git"
      hub.data_config.ssh_config.ssh_key.must_equal "default"
    end

    it "works with a detailed config" do

      hub = Config::Hub.from_string <<-STR
        project_repo do |p|
          p.url = "github-project:rcarver/config-example.git"
          p.hostname = "github.com"
          p.port = 99
          p.user = "buster"
          p.ssh_key = "project"
        end
        data_repo do |p|
          p.url = "git@github-data:rcarver/config-example-data.git"
          p.hostname = "github.com"
          p.ssh_key = "data"
        end
        ssh_config do |c|
          c.url = "git@github.com:org/config-more.git"
          c.ssh_key = "org"
        end
      STR

      hub.project_config.url.must_equal "github-project:rcarver/config-example.git"
      hub.data_config.url.must_equal "git@github-data:rcarver/config-example-data.git"

      hub.ssh_configs.size.must_equal 3
      project, data, github = hub.ssh_configs

      project.host.must_equal "github-project"
      project.hostname.must_equal "github.com"
      project.user.must_equal "buster"
      project.port.must_equal 99
      project.ssh_key.must_equal "project"

      data.host.must_equal "github-data"
      data.hostname.must_equal "github.com"
      data.user.must_equal "git"
      data.ssh_key.must_equal "data"

      github.host.must_equal "github.com"
      github.user.must_equal "git"
      github.ssh_key.must_equal "org"
    end

    it "provides useful information for a syntax error" do
      file = __FILE__
      line = __LINE__ + 4 # why is this 4? 3 makes more sense to me.
      begin
        Config::Hub.from_string <<-STR, __FILE__, __LINE__
          xproject_repo '../project.git'
        STR
      rescue => e
        e.class.must_equal NoMethodError
        e.message.must_equal %(undefined method `xproject_repo' for <Hub>:RbConfig::DSL::HubDSL)
        e.backtrace.first.must_equal "#{file}:#{line}:in `from_string'"
      end
    end
  end
end

describe "filesystem", Config::Hub do

  describe ".from_file" do

    let(:file) { tmpdir + "sample.rb" }

    it "works" do

      file.open("w") do |f|
        f.puts "project_repo '../project.git'"
      end

      hub = Config::Hub.from_file(file)
      hub.project_config.url.must_equal "../project.git"
    end

    it "provides useful information for an error" do

      file.open("w") do |f|
        f.puts "# the first line"
        f.puts "xproject_repo '../project.git'"
      end

      begin
        Config::Hub.from_file(file)
      rescue => e
        e.class.must_equal NoMethodError
        e.message.must_equal %(undefined method `xproject_repo' for <Hub>:RbConfig::DSL::HubDSL)
        e.backtrace.first.must_equal "#{file}:2:in `from_string'"
      end
    end
  end
end



