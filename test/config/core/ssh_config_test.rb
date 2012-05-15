require 'helper'

describe Config::Core::SSHConfig do

  subject { Config::Core::SSHConfig.new }

  it "defaults hostname to host" do
    subject.hostname.must_equal nil
    subject.host = "foo.com"
    subject.hostname.must_equal "foo.com"
    subject.hostname = "bar.com"
    subject.hostname.must_equal "bar.com"
  end

  it "defaults the port to 22" do
    subject.port.must_equal 22
    subject.port = 99
    subject.port.must_equal 99
  end

  it "generates a Host stanza" do
    subject.host = "examples-are-fun"
    subject.user = "foo"
    subject.hostname = "example.com"
    subject.port = 99
    subject.ssh_key = "default"
    subject.extras << "PreferredAuthentications publickey"

    ssh_key = MiniTest::Mock.new
    ssh_key.expect(:path, "/etc/config/default")

    data_dir = MiniTest::Mock.new
    data_dir.expect(:ssh_key, ssh_key, ["default"])

    subject.to_host_config(data_dir).must_equal <<-STR
Host examples-are-fun
  Port 99
  Hostname example.com
  User foo
  IdentityFile /etc/config/default
  PreferredAuthentications publickey
    STR

    ssh_key.verify
    data_dir.verify
  end

end
