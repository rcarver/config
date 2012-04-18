require 'helper'

describe Config::Core::Facts do

  specify ".read calls ohai" do
    if ENV['SLOW_TESTS']
      facts = Config::Core::Facts.read do |ohai|
        ohai.require_plugin("ruby")
      end
      facts.languages.ruby.version.must_equal RUBY_VERSION
    else
      skip "SLOW_TESTS are disabled"
    end
  end
end
