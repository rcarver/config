require 'helper'

describe Config::Facts, "using ohai" do

  specify ".invent calls ohai" do
    facts = Config::Facts.invent
    facts.languages.ruby.version.must_equal RUBY_VERSION
  end
end
