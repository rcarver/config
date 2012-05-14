require 'helper'

describe Config::Hub do

  describe ".from_string" do

    it "works" do
      hub = Config::Hub.from_string <<-STR
        git_project '../project.git'
        git_data    '../data.git'
      STR
      hub.git_project_url.must_equal '../project.git'
      hub.git_data_url.must_equal '../data.git'
    end

    it "provides useful information for a syntax error" do
      file = __FILE__
      line = __LINE__ + 4 # why is this 4? 3 makes more sense to me.
      begin
        Config::Hub.from_string <<-STR, __FILE__, __LINE__
          x_git_project '../project.git'
        STR
      rescue => e
        e.class.must_equal NoMethodError
        e.message.must_equal %(undefined method `x_git_project' for <Hub>:RbConfig::DSL::HubDSL)
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
        f.puts "git_project '../project.git'"
      end
      hub = Config::Hub.from_file(file)
      hub.git_project_url.must_equal "../project.git"
    end

    it "provides useful information for an error" do
      file.open("w") do |f|
        f.puts "# the first line"
        f.puts "x_git_project '../project.git'"
      end
      begin
        Config::Hub.from_file(file)
      rescue => e
        e.class.must_equal NoMethodError
        e.message.must_equal %(undefined method `x_git_project' for <Hub>:RbConfig::DSL::HubDSL)
        e.backtrace.first.must_equal "#{file}:2:in `from_string'"
      end
    end
  end
end



