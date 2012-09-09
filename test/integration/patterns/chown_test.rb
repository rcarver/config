require 'helper'

describe Config::Patterns::Chown do

  subject { Config::Patterns::Chown.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:path]
  end

  specify "validity" do
    subject.path = "/tmp/file.rb"
    subject.attribute_errors.must_be_empty
  end

  describe "#to_s" do

    before do
      subject.path = "/tmp/file"
    end

    specify "with an owner" do
      subject.owner = "www"
      subject.to_s.must_equal "chown www /tmp/file"
    end

    specify "with a group" do
      subject.group = "admin"
      subject.to_s.must_equal "chown admin /tmp/file"
    end

    specify "with an owner and a group" do
      subject.owner = "www"
      subject.group = "admin"
      subject.to_s.must_equal "chown www:admin /tmp/file"
    end

    specify "recursively" do
      subject.owner = "www"
      subject.recursive = true
      subject.to_s.must_equal "chown www -R /tmp/file"
    end
  end
end

describe "filesystem", Config::Patterns::Chown do

  subject { Config::Patterns::Chown.new }

  let(:path) { tmpdir + "test.txt" }
  let(:fu) { MiniTest::Mock.new }

  before do
    path.open("w") { |f| f.print "ok" }
    subject.path = path.to_s
    subject.fu = fu
  end

  def execute(run_mode)
    subject.prepare
    subject.public_send(run_mode)
  end

  describe "#create" do

    describe "changing the owner" do

      before do
        @user = "root"
        @uid = 0
      end

      it "sets the owner" do
        subject.owner = @user

        fu.expect(:chown, nil, [@uid, nil, path.to_s])

        execute :create
        subject.changes.to_a.must_equal ["Set owner to #{@user}"]
      end

      it "sets the owner recursively" do
        subject.owner = @user
        subject.recursive = true

        fu.expect(:chown_r, nil, [@uid, nil, path.to_s])

        execute :create
        subject.changes.to_a.must_equal ["Set owner to #{@user}"]
      end

      it "does nothing if the correct owner is already set" do
        current_uid = ::File.stat(path).uid
        current_owner = ::Etc.getpwuid(current_uid).name

        subject.owner = current_owner

        execute :create
        subject.changes.to_a.must_equal []
      end
    end

    describe "changing the group" do

      before do
        @group = "admin"
        @gid = Etc.getgrnam(@group).gid
      end

      it "sets the group" do
        subject.group = @group

        fu.expect(:chown, nil, [nil, @gid, path.to_s])

        execute :create
        subject.changes.to_a.must_equal ["Set group to #{@group}"]
      end

      it "sets the group recursively" do
        subject.group = @group
        subject.recursive = true

        fu.expect(:chown_r, nil, [nil, @gid, path.to_s])

        execute :create
        subject.changes.to_a.must_equal ["Set group to #{@group}"]
      end

      it "does nothing if the correct owner is already set" do
        current_gid = ::File.stat(path).gid
        current_group = ::Etc.getgrgid(current_gid).name

        subject.group = current_group

        execute :create
        subject.changes.to_a.must_equal []
      end
    end
  end
end


