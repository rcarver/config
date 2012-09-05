require 'helper'

describe "filesystem", Config::Core::Directories do

  let(:system_dir) { tmpdir + "system" }
  let(:current_dir) { tmpdir + "current" }

  before do
    current_dir.mkdir
  end

  describe "when constructed with two directories" do

    subject { Config::Core::Directories.new(system_dir, current_dir) }

    describe "and the system dir exists" do

      before do
        system_dir.mkdir
      end

      specify "#project_dir" do
        subject.project_dir.must_equal system_dir + "project"
      end

      specify "#private_data_dir" do
        subject.private_data_dir.must_equal system_dir
      end

      specify "#database_dir" do
        subject.database_dir.must_equal system_dir + "database"
      end

      specify "#run_dir" do
        subject.run_dir.must_equal system_dir + "run"
      end
    end

    describe "and the system dir does not exist" do

      specify "#project_dir" do
        subject.project_dir.must_equal current_dir
      end

      specify "#private_data_dir" do
        subject.private_data_dir.must_equal current_dir + ".data"
      end

      specify "#database_dir" do
        subject.database_dir.must_equal current_dir + ".data/database"
      end

      specify "#run_dir" do
        subject.run_dir.must_equal current_dir
      end
    end
  end

  describe "when constructed with only one directory" do

    subject { Config::Core::Directories.new(system_dir) }

    specify "#project_dir" do
      subject.project_dir.must_equal system_dir + "project"
    end

    specify "#private_data_dir" do
      subject.private_data_dir.must_equal system_dir
    end

    specify "#database_dir" do
      subject.database_dir.must_equal system_dir + "database"
    end

    specify "#run_dir" do
      subject.run_dir.must_equal system_dir + "run"
    end
  end

  describe "#create_run_dir!" do

    subject { Config::Core::Directories.new(system_dir, current_dir) }

    describe "when the system dir exists" do

      before do
        system_dir.mkdir
      end

      it "creates the dir" do
        subject.create_run_dir!
        subject.run_dir.must_be :exist?
      end

      it "recreates it if it exists" do
        subject.run_dir.mkdir
        (subject.run_dir + "file").open("w") { |f| f.print "yay" }
        subject.create_run_dir!
        subject.run_dir.must_be :exist?
        (subject.run_dir + "file").wont_be :exist?
      end
    end

    describe "when the system dir does not exist" do

      it "does nothing" do
        (subject.run_dir + "file").open("w") { |f| f.print "yay" }
        subject.create_run_dir!
        subject.run_dir.must_be :exist?
        (subject.run_dir + "file").must_be :exist?
      end
    end
  end
end

