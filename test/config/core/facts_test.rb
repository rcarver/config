require 'helper'

describe Config::Core::Facts do

  let(:hash) {
    # Copied from ohai output.
    {
      "languages" => {
        "ruby" => {
          "platform" => "x86_64-darwin11.2.0",
          "version" => "1.9.3"
        }
      },
      "kernel" => {
        "name" => "Darwin",
      }
    }
  }

  subject { Config::Core::Facts.new(hash) }

  specify "#to_s" do
    subject.to_s.must_equal "[Facts: kernel,languages]"
  end

  specify "equality" do
    a = Config::Core::Facts.new(hash)
    b = Config::Core::Facts.new(hash)
    c = Config::Core::Facts.new(hash.merge("other" => "here"))
    a.must_equal b
    b.must_equal a
    a.wont_equal c
    c.wont_equal a
  end

  specify "#as_json" do
    subject.as_json.must_equal hash
  end

  specify ".from_json" do
    facts = Config::Core::Facts.from_json(hash)
    facts.must_equal subject
  end

  it "returns any value via hash syntax" do
    subject["languages"].must_be_instance_of Hash
    subject["languages"].keys.must_equal ["ruby"]
    subject["languages"]["ruby"].must_be_instance_of Hash
    subject["languages"]["ruby"]["version"].must_equal "1.9.3"
  end

  it "returns nil for nonexistent value" do
    subject["nothing"].must_equal nil
  end

  it "allows chain syntax" do
    subject.languages.ruby.version.must_equal "1.9.3"
  end

  it "describes each chain link" do
    subject.languages.to_s.must_equal "[FactChain languages => ruby]"
    subject.languages.ruby.to_s.must_equal "[FactChain languages.ruby => platform,version]"
  end

  it "fails if an unknown chain link is accessed" do
    skip "think about this more"
    begin
      subject.languages.nothing.here
      fail
    rescue RuntimeError => e
      e.message.must_equal "[Facts] There is no key 'here' for 'languages.nothing'"
    end
  end

end
