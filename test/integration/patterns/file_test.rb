require 'helper'
require 'ostruct'

describe Config::Patterns::File do

  subject { Config::Patterns::File.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:path]
  end

  specify "validity" do
    subject.path = "/tmp/file.rb"
    subject.error_messages.must_be_empty
  end

  specify "#to_s" do
    subject.path = "/tmp//file.rb"
    subject.to_s.must_equal "[File /tmp/file.rb]"
  end
end

describe "filesystem", Config::Patterns::File do

  subject { Config::Patterns::File.new }

  let(:path) { tmpdir + "test.txt" }

  before do
    subject.path = path.to_s
  end

  class SampleTemplateContext
    def initialize(name)
      @name = name
    end
    attr_reader :name
    def get_binding
      binding
    end
  end

  describe "#create" do

    describe "with static content" do

      before do
        subject.content = "hello world"
      end

      it "writes the file" do
        subject.create
        path.read.must_equal "hello world"
        subject.changes.must_include "created"
      end

      it "does not change the file if it exists and is equivalent" do
        path.open("w") { |f| f.print "hello world" }
        subject.create
        subject.wont_be :changed?
      end

      it "changes the file if the content is different" do
        path.open("w") { |f| f.print "goodbye" }
        subject.create
        subject.changes.must_include "updated"
      end
    end

    describe "with a template" do

      before do
        (tmpdir + "tmpl.erb").open("w") do |f|
          f.print "<%= name %>"
        end
        subject.template_path = tmpdir + "tmpl.erb"
        subject.template_context = SampleTemplateContext.new("bob")
      end

      it "renders the file" do
        subject.create
        path.read.must_equal "bob"
        subject.changes.must_include "created"
      end

      it "does not change the file if it exists and is equivalent" do
        path.open("w") { |f| f.print "bob" }
        subject.create
        subject.wont_be :changed?
      end

      it "changes the file if the content is different" do
        path.open("w") { |f| f.print "joe" }
        subject.create
        subject.changes.must_include "updated"
      end

      # TODO: validate attrs
    end
  end

  describe "#destroy" do

    it "does nothing if the file does not exist" do
      subject.destroy
      tmpdir.must_be :exist?
      subject.wont_be :changed?
    end

    it "deletes the file" do
      path.open("w") { |f| f.print "ok" }
      subject.destroy
      path.wont_be :exist?
      tmpdir.must_be :exist?
      subject.changes.must_include "deleted"
    end
  end
end

