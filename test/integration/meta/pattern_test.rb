require 'helper'

describe Config::Meta::Pattern do

  subject { Config::Meta::Pattern.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:root, :topic, :name]
  end

  specify "validity" do
    subject.root = "/tmp"
    subject.name = "tmp"
    subject.topic = "misc"
    subject.error_messages.must_be_empty
  end
end

describe "filesystem", Config::Meta::Pattern do

  subject { Config::Meta::Pattern.new }

  it "creates a new pattern template" do

    # Pattern topic must exist.
    (tmpdir + "patterns" + "nginx").mkpath

    # README should exist.
    (tmpdir + "patterns" + "nginx" + "README.md").open("w") do |f|
      f.puts "# NGINX"
    end

    subject.root = tmpdir
    subject.topic = "nginx"
    subject.name = "service"

    execute_pattern

    (tmpdir + "patterns" + "nginx").must_be :exist?

    (tmpdir + "patterns" + "nginx" + "service.rb").must_be :exist?
    (tmpdir + "patterns" + "nginx" + "service.rb").read.must_equal <<-STR.dent
      class Nginx::Service < Config::Pattern

        desc "The name"
        key  :name

        desc "The value"
        attr :value

        def call
          # add patterns here
        end
      end
    STR

    (tmpdir + "patterns" + "nginx" + "README.md").must_be :exist?
    (tmpdir + "patterns" + "nginx" + "README.md").read.must_equal <<-STR.dent
      # NGINX

      ## Service

      **TODO** Describe the purpose of this pattern.
    STR
  end
end
