require 'helper'

describe "slow test", Config::Core::Facts do

  specify ".read calls ohai" do
    facts = Config::Core::Facts.read do |ohai|
      ohai.require_plugin("ruby")
    end
    facts.languages.ruby.version.must_equal RUBY_VERSION
  end
end
