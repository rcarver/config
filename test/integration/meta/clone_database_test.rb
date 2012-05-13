require 'helper'

describe Config::Meta::CloneDatabase do

  subject { Config::Meta::CloneDatabase.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:url, :path]
  end

  specify "validity" do
    subject.path = "/tmp"
    subject.url = "tmp"
    subject.error_messages.must_be_empty
  end
end

describe "filesystem", Config::Meta::CloneDatabase do

  # Tests are in slow/clone_database_test.rb

end


