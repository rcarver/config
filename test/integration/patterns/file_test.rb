require 'helper'
require 'ostruct'

describe Config::Patterns::File do

  subject { Config::Patterns::File.new }

  specify "keys" do
    subject.key_attributes.keys.must_equal [:path]
  end

  specify "validity" do
    subject.path = "/tmp/file.rb"
    subject.attribute_errors.must_be_empty
  end

  specify "#to_s" do
    subject.path = "/tmp//file.rb"
    subject.to_s.must_equal "[File /tmp/file.rb]"
  end

  specify "#to_s without a path" do
    subject.to_s.must_equal "[File]"
  end

  describe "#validate" do

    before do
      subject.path = "/tmp"
    end

    let(:fake_context_class) { 
      Class.new do
        def get_binding; binding end
      end
    }

    it "must have content of some form" do
      subject.validate
      subject.error_messages.must_equal [
        "You must set either `content` or (`template_path` and `template_context`)"
      ]
    end

    it "may have explicit content" do
      subject.content = "ok"
      subject.validate
      subject.error_messages.must_equal []
    end

    it "may have template content" do
      subject.template_path = __FILE__
      subject.template_context = fake_context_class.new
      subject.validate
      subject.error_messages.must_equal []
    end

    specify "template_path must be a real file" do
      subject.template_path = "foo.erb"
      subject.template_context = fake_context_class.new
      subject.validate
      subject.error_messages.must_equal [
        "template_path foo.erb does not exist"
      ]
    end

    specify "template_context must define #get_binding" do
      subject.template_path = __FILE__
      subject.template_context = Object.new
      subject.validate
      subject.error_messages.must_equal [
        "template_context must define #get_binding"
      ]
    end
  end

  describe "#prepare" do

    it "logs explicit content" do
      skip
    end

    it "logs template content" do
      skip
    end

    it "converts non-String content to String" do
      subject.content = 123
      subject.prepare
      subject.instance_variable_get(:@new_content).must_equal "123"
    end
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

  def execute(run_mode)
    subject.prepare
    subject.public_send(run_mode)
  end

  describe "#create" do

    describe "operation = :write" do

      before do
        subject.content = "hello world"
      end

      it "writes the file" do
        execute :create
        path.read.must_equal "hello world"
        subject.changes.must_include "created"
      end

      it "does not change the file if it exists and is equivalent" do
        path.open("w") { |f| f.print "hello world" }
        execute :create
        subject.wont_be :changed?
      end

      it "changes the file if the content is different" do
        path.open("w") { |f| f.print "goodbye" }
        execute :create
        subject.changes.must_include "updated"
      end

      it "logs an identical file" do
        path.open("w") { |f| f.print subject.content }
        execute :create
        subject.changes.must_be_empty
        log_string.must_equal <<-STR.dent(2)
            >>>
            hello world
            <<<
          identical
        STR
      end
    end

    describe "operation = :append" do

      before do
        subject.content = "hello world"
        subject.append!
      end

      it "creates the file" do
        execute :create
        subject.changes.must_include "created"
        path.read.must_equal "hello world"
      end

      it "appends the file" do
        path.open("w") { |f| f.print "HERE" }
        execute :create
        subject.changes.must_include "appended"
        path.read.must_equal "HEREhello world"
      end
    end

    describe "operation = :create" do

      before do
        subject.content = "hello\nworld"
        subject.only_create!
      end

      it "creates the file" do
        execute :create
        subject.changes.must_include "created"
        path.read.must_equal "hello\nworld"
      end

      it "does not change the file" do
        path.open("w") { |f| f.print "HERE" }
        execute :create
        subject.wont_be :changed?
        path.read.must_equal "HERE"
      end

      it "logs the file content" do
        execute :create
        log_string.must_equal <<-STR.dent(2)
            >>>
            hello
            world
            <<<
          created
        STR
      end
    end

    describe "with a template" do

      before do
        (tmpdir + "tmpl.erb").open("w") do |f|
          f.print "Hello <%= name %>"
        end
        subject.template_path = tmpdir + "tmpl.erb"
        subject.template_context = SampleTemplateContext.new("bob")
      end

      it "renders the file" do
        execute :create
        path.read.must_equal "Hello bob"
        subject.changes.must_include "created"
      end

      it "does not change the file if it exists and is equivalent" do
        path.open("w") { |f| f.print "Hello bob" }
        execute :create
        subject.wont_be :changed?
      end

      it "changes the file if the content is different" do
        path.open("w") { |f| f.print "Hello joe" }
        execute :create
        subject.changes.must_include "updated"
      end

      it "logs a debug template" do
        execute :create
        log_string.must_equal <<-STR.dent(2)
            >>>
            Hello [name:bob]
            <<<
          created
        STR
      end

      it "colorizes the debug template" do
        log.color = true
        execute :create
        log_string.must_equal <<-STR.dent(2)
            >>>
            Hello \e[34mname:\e[0m\e[31mbob\e[0m
            <<<
          created
        STR
      end
    end
  end

  describe "#destroy" do

    before do
      subject.content = "hello world"
    end

    it "does nothing if the file does not exist" do
      execute :destroy
      tmpdir.must_be :exist?
      subject.wont_be :changed?
    end

    it "deletes the file" do
      path.open("w") { |f| f.print "ok" }
      execute :destroy
      path.wont_be :exist?
      tmpdir.must_be :exist?
      subject.changes.must_include "deleted"
    end
  end
end

