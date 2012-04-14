require 'helper'

describe Config::Patterns::Directory do

  subject { Config::Patterns::Directory.new }

  it "uses the path as its key" do
    subject.key_attributes.keys.must_equal [:path]
  end

  it "is valid" do
    subject.path = "/tmp"
    subject.error_messages.must_be_empty
  end

end
