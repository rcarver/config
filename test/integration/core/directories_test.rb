require 'helper'

describe "filesystem", Config::Core::Directories do

  let(:system_dir) { tmpdir + "system" }
  let(:current_dir) { tmpdir + "current" }

  before do
    current_dir.mkdir
  end

  subject { Config::Core::Directories.new(system_dir, current_dir) }

  def create_system_dir
    system_dir.mkdir
  end

  describe ".project_dir" do

    it "loads from the system dir" do
      create_system_dir
      subject.project_dir.must_equal system_dir + "project"
    end

    it "loads from the current dir" do
      subject.project_dir.must_equal current_dir
    end
  end

  describe ".private_data_dir" do

    it "loads from the system dir" do
      create_system_dir
      subject.private_data_dir.must_equal system_dir
    end

    it "loads from the current dir" do
      subject.private_data_dir.must_equal current_dir + ".data"
    end
  end

  describe ".database_dir" do

    it "loads from the system dir" do
      create_system_dir
      subject.database_dir.must_equal system_dir + "database"
    end

    it "loads from the current dir" do
      subject.database_dir.must_equal current_dir + ".data" + "database"
    end
  end

  describe ".run_dir" do

    it "runs from the system dir" do
      create_system_dir
      subject.run_dir.must_equal system_dir + "run"
    end

    it "loads from the current dir" do
      subject.run_dir.must_equal current_dir
    end
  end
end

