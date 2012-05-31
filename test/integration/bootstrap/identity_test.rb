require 'helper'

describe Config::Bootstrap::Identity do

  subject { Config::Bootstrap::Identity.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:blueprint, :cluster, :identity, :dns_domain_name]
  end

  specify "validity" do
    subject.path = "/tmp/file"
    subject.blueprint = "webserver"
    subject.cluster = "production"
    subject.identity = "xyz"
    subject.dns_domain_name = "internal.example.com"
    subject.secret = "shhh"
    subject.validate
    subject.error_messages.must_be_empty
  end
end

describe "filesystem", Config::Bootstrap::Identity do

  subject { Config::Bootstrap::Identity.new }

  it "writes a script" do

    subject.path = tmpdir + "identity"
    subject.blueprint = "webserver"
    subject.cluster = "production"
    subject.identity = "xyz"
    subject.dns_domain_name = "internal.example.com"
    subject.secret = "shhh"

    execute_pattern

    (tmpdir + "identity").must_be :exist?
    contents = (tmpdir + "identity").read

    contents.must_include "echo production-webserver-xyz > /etc/hostname"
    contents.must_include "hostname production-webserver-xyz"
    contents.must_include "echo \"$ip_address production-webserver-xyz.internal.example.com production-webserver-xyz\" >> /etc/hosts"
  end
end

