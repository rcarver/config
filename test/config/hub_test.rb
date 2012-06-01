require 'helper'

describe Config::Hub do

  subject { Config::Hub.new }

  FakeHost = Struct.new(:hostname)

  def ssh_config(host)
    config = MiniTest::Mock.new
    config.expect(:ssh_config, h(host))
    config
  end

  def h(name)
    FakeHost.new(name)
  end

  describe "#ssh_hostnames" do

    it "is empty" do
      subject.ssh_hostnames.must_be_empty
    end

    it "includes the ssh_configs" do
      subject.ssh_configs = [h("a"), h("b")]
      subject.ssh_hostnames.must_equal ["a", "b"]
    end

    it "includes the project config" do
      subject.project_config = ssh_config("c")
      subject.ssh_hostnames.must_equal ["c"]
    end

    it "includes the data config" do
      subject.data_config = ssh_config("c")
      subject.ssh_hostnames.must_equal ["c"]
    end

    it "is a unique set of all hosts" do
      subject.ssh_configs = [h("a"), h("b"), h("c")]
      subject.project_config = ssh_config("c")
      subject.data_config = ssh_config("c")
      subject.ssh_hostnames.must_equal ["a", "b", "c"]
    end
  end
end
