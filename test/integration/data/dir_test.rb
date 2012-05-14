require 'helper'

describe "filesystem", Config::Data::Dir do

  subject { Config::Data::Dir.new(tmpdir) }

  describe "#git_ssh_key" do

    it "returns a file" do
      file = subject.git_ssh_key(:default)
      file.must_be_instance_of Config::Data::File
      file.path.must_equal (tmpdir + "git-ssh-key-default").to_s
    end
  end

  describe "#all_git_ssh_keys" do

    it "returns a file for each private key in the dir" do
      (tmpdir + "git-ssh-key-default").open("w" ) { |f| f.print "ok" }
      (tmpdir + "git-ssh-key-default.pub").open("w" ) { |f| f.print "ok" }
      (tmpdir + "git-ssh-key-other").open("w" ) { |f| f.print "ok" }

      keys = subject.all_git_ssh_keys
      keys.map { |file| file.name }.must_equal ["git-ssh-key-default", "git-ssh-key-other"]
    end
  end
end
