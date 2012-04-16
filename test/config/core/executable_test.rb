require 'helper'

describe Config::Core::Executable do

  let(:klass) {
    Class.new do
      include Config::Core::Executable
      include Config::Core::Loggable

      attr_reader :result

      def to_s
        "Test"
      end

      def create
        @result = "created"
      end

      def destroy
        @result = "destroyed"
      end
    end
  }

  subject { klass.new }

  def log
    log_string.chomp
  end

  describe "pattern hierarchy" do

    let(:a) { klass.new }
    let(:b) { klass.new }
    let(:c) { klass.new }

    before do
      c.parent = b
      b.parent = a
    end

    describe "#parents" do
      it "exposes the parent list" do
        c.parents.must_equal [b, a]
        b.parents.must_equal [a]
        a.parents.must_equal []
      end
    end

    describe "#skip_parent?" do
      it "is false if no parents are skipped" do
        c.wont_be :skip_parent?
        b.wont_be :skip_parent?
        a.wont_be :skip_parent?
      end
      it "is false if the pattern itself is skipped" do
        c.run_mode = :skip
        c.wont_be :skip_parent?
      end
      it "is true if any parent is skipped" do
        b.run_mode = :skip
        c.must_be :skip_parent?
      end
    end
  end

  describe "#execute" do

    it "creates by default" do
      subject.execute
      subject.result.must_equal "created"
    end
    it "creates" do
      subject.run_mode = :create
      subject.execute
      subject.result.must_equal "created"
      log.must_equal "Create Test"
    end
    it "destroys" do
      subject.run_mode = :destroy
      subject.execute
      subject.result.must_equal "destroyed"
      log.must_equal "Destroy Test"
    end
    it "skips" do
      subject.run_mode = :skip
      subject.execute
      subject.result.must_equal nil
      log.must_equal "Skip Test"
    end
    it "skips if a parent is skipped" do
      parent = klass.new
      parent.run_mode = :skip
      subject.parent = parent
      subject.execute
      subject.result.must_equal nil
      log.must_equal "Skip Create Test"
    end
    it "describes both a parent skip and its own skip" do
      parent = klass.new
      parent.run_mode = :skip
      subject.parent = parent
      subject.run_mode = :skip
      subject.execute
      subject.result.must_equal nil
      log.must_equal "Skip Test"
    end
    it "does not support other run modes" do
      subject.run_mode = :foobar
      proc { subject.execute }.must_raise RuntimeError
    end

    describe "with noop" do

      before do
        subject.noop!
      end

      it "logs create but does not execute" do
        subject.run_mode = :create
        subject.execute
        subject.result.must_equal nil
        log.must_equal "Create Test"
      end
      it "logs destroy but does not execute" do
        subject.run_mode = :destroy
        subject.execute
        subject.result.must_equal nil
        log.must_equal "Destroy Test"
      end
    end
  end
end
