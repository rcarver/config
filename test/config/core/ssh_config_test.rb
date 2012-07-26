require 'helper'

describe Config::Core::SSHConfig do

  subject { Config::Core::SSHConfig.new }

  it "defaults the ssh_key" do
    subject.ssh_key.must_equal "default"
    subject.ssh_key = "other"
    subject.ssh_key.must_equal "other"
  end

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

    private_data = MiniTest::Mock.new
    private_data.expect(:ssh_key, ssh_key, ["default"])

    subject.to_host_config(private_data).must_equal <<-STR
Host examples-are-fun
  Port 99
  Hostname example.com
  User foo
  IdentityFile /etc/config/default
  PreferredAuthentications publickey
    STR

    ssh_key.verify
    private_data.verify
  end

end
