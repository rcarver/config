require 'helper'
require 'ostruct'

describe Config::Patterns::Package do

  subject { Config::Patterns::Package.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:name]
  end

  specify "validity" do
    subject.name = "nginx"
    subject.attribute_errors.must_be_empty
  end

  specify "#to_s" do
    subject.name = "nginx"
    subject.to_s.must_equal %(Package "nginx")
    subject.version = "1.1"
    subject.to_s.must_equal %(Package "nginx" at "1.1")
  end
  
  def call_pattern
    subject.accumulation = Config::Core::Accumulation.new
    subject.prepare
    subject.call
    subject.accumulation.to_a
  end

  describe "#call" do

    it "installs without a version" do
      subject.name = "nginx"
      patterns = call_pattern
      patterns.size.must_equal 2

      bash = patterns.find { |p| p.is_a? Config::Patterns::Bash }
      bash.name.must_equal "install nginx"

      script = patterns.find { |p| p.is_a? Config::Patterns::Script }
      script.name.must_equal "install nginx"
      script.code.must_equal "apt-get install nginx -y -q"
      script.reverse.must_equal "apt-get remove nginx -y -q"
    end

    it "installs with a version" do
      subject.name = "nginx"
      subject.version = "1.1"
      patterns = call_pattern
      patterns.size.must_equal 2

      bash = patterns.find { |p| p.is_a? Config::Patterns::Bash }
      bash.name.must_equal "install nginx at 1.1"

      script = patterns.find { |p| p.is_a? Config::Patterns::Script }
      script.name.must_equal "install nginx at 1.1"
      script.code.must_equal "apt-get install nginx --version=1.1 -y -q"
      script.reverse.must_equal "apt-get remove nginx -y -q"
    end
  end
end
