require 'helper'

describe "filesystem", Config::Data::Dir do

  subject { Config::Data::Dir.new(tmpdir) }

  describe "#ssh_key" do

    it "returns a file" do
      file = subject.ssh_key(:default)
      file.must_be_instance_of Config::Data::File
      file.path.must_equal (tmpdir + "ssh-key-default").to_s
    end
  end
end
