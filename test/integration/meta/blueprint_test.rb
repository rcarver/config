require 'helper'

describe Config::Meta::Blueprint do

  subject { Config::Meta::Blueprint.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:root, :name]
  end

  specify "validity" do
    subject.root = "/tmp"
    subject.name = "tmp"
    subject.error_messages.must_be_empty
  end
end

describe "filesystem", Config::Meta::Blueprint do

  subject { Config::Meta::Blueprint.new }

  it "creates a new blueprint" do

    subject.root = tmpdir
    subject.name = "webserver"

    execute_pattern

    (tmpdir + "blueprints" + "webserver.rb").must_be :exist?
  end
end

