require 'helper'

describe Config::Bootstrap::Access do

  subject { Config::Bootstrap::Access.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:ssh_host]
  end

  specify "validity" do
    subject.path = "/tmp"
    subject.ssh_host = "github.com"
    subject.ssh_user = "git"
    subject.ssh_keys = { a: "ok" }
    subject.error_messages.must_be_empty
  end
end

describe "filesystem", Config::Bootstrap::Access do

  subject { Config::Bootstrap::Access.new }

  it "writes a script" do

    subject.path = tmpdir + "access"
    subject.ssh_host = "github.com"
    subject.ssh_user = "git"
    subject.ssh_keys = { a: "ok", b: "cool" }

    execute_pattern

    (tmpdir + "access").must_be :exist?
    contents = (tmpdir + "access").read

    contents.must_include "echo 'ok' > /etc/config/a"
    contents.must_include "echo 'cool' > /etc/config/b"
  end
end


