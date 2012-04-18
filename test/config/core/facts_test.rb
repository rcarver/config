require 'helper'

describe Config::Core::Facts do

  let(:mash) {
    Mash.new(
      # Copied from ohai output.
      "languages" => {
        "ruby" => {
          "platform" => "x86_64-darwin11.2.0",
          "version" => "1.9.3"
        }
      },
      "kernel" => {
        "name" => "Darwin",
      }
    )
  }

  subject { Config::Core::Facts.new(mash) }

  specify "#to_s" do
    subject.to_s.must_equal "[Facts: kernel,languages]"
  end

  it "returns any value via hash syntax" do
    subject["languages"].must_be_instance_of Mash
    subject["languages"].keys.must_equal ["ruby"]
    subject["languages"]["ruby"].must_be_instance_of Mash
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
