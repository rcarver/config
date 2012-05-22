require 'helper'

describe Config::Bootstrap::Access do

  subject { Config::Bootstrap::Access.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal []
  end

  specify "validity" do
    subject.path = "/tmp"
    subject.ssh_configs = []
    subject.ssh_keys = { a: "ok" }
    subject.ssh_known_hosts = { "github.com" => "signature" }
    subject.error_messages.must_be_empty
  end
end

describe "filesystem", Config::Bootstrap::Access do

  subject { Config::Bootstrap::Access.new }

  it "writes a script" do

    subject.path = tmpdir + "access"
    subject.ssh_configs = ["Host config1", "Host config2"]
    subject.ssh_keys = { "/etc/config/a" => "ok", "/etc/config/b" => "cool" }
    subject.ssh_known_hosts = { "github.com" => "signature" }

    execute_pattern

    (tmpdir + "access").must_be :exist?
    contents = (tmpdir + "access").read

    contents.must_include "echo 'signature' >> /root/.ssh/known_hosts"

    contents.must_include "echo 'Host config1' >> /root/.ssh/config"
    contents.must_include "echo 'Host config2' >> /root/.ssh/config"

    contents.must_include "echo 'ok' > /etc/config/a"
    contents.must_include "echo 'cool' > /etc/config/b"
  end
end


