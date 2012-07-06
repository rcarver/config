require 'helper'

describe "filesystem", Config do

  let(:system_dir) { tmpdir + "system" }

  before do
    @current_dir = Dir.pwd
    Dir.chdir tmpdir
  end

  after do
    Dir.chdir @current_dir
  end

  def setup_system_dir
    system_dir.mkdir
    Config.system_dir = system_dir
  end

  specify ".system_dir" do
    Config.system_dir.must_equal Pathname.new("/etc/config")
  end

  describe ".project" do
    it "returns a project" do
      Config.project.must_be_instance_of Config::Project
    end
  end

  describe ".project_loader" do
    it "loads from the global dir if it exists" do
      setup_system_dir
      loader = Config.project_loader
      loader.path.must_equal system_dir + "project"
    end
    it "loads from the local dir" do
      loader = Config.project_loader
      loader.path.must_equal tmpdir
    end
  end

  describe ".project_data" do
    it "loads from the global dir if it exists" do
      setup_system_dir
      loader = Config.project_data
      loader.path.must_equal system_dir + "project-data"
    end
    it "loads from the local dir" do
      loader = Config.project_data
      loader.path.must_equal tmpdir + ".data"
    end
  end

  describe ".nodes" do
    it "returns nodes" do
      Config.nodes.must_be_instance_of Config::Nodes
    end
  end
end
