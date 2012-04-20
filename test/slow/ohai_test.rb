require 'helper'

describe Config::Core::Facts, "using ohai" do

  specify ".invent calls ohai" do
    facts = Config::Core::Facts.invent
    facts.languages.ruby.version.must_equal RUBY_VERSION
  end
end
