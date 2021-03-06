require 'helper'

describe Config::Core::Executable do

  let(:klass) {
    Class.new do
      include Config::Core::Executable
      include Config::Core::Loggable

      def initialize
        @result = []
      end

      def to_s
        "Test"
      end

      def result
        @result.join(' ')
      end

      def prepare
        @result << "prepared"
        log << "preparing"
      end

      def create
        @result << "created"
        log << "creating"
      end

      def destroy
        @result << "destroyed"
        log << "destroying"
      end
    end
  }

  subject { klass.new }

  def log
    log_string
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
      subject.result.must_equal "prepared created"
    end
    it "creates" do
      subject.run_mode = :create
      subject.execute
      subject.result.must_equal "prepared created"
      log.must_equal <<-STR.dent
        + Test
          preparing
          creating
      STR
    end
    it "destroys" do
      subject.run_mode = :destroy
      subject.execute
      subject.result.must_equal "prepared destroyed"
      log.must_equal <<-STR.dent
        - Test
          preparing
          destroying
      STR
    end
    it "skips" do
      subject.run_mode = :skip
      subject.execute
      subject.result.must_equal ""
      log.must_equal <<-STR.dent
        SKIP Test
      STR
    end
    it "skips if a parent is skipped" do
      parent = klass.new
      parent.run_mode = :skip
      subject.parent = parent
      subject.execute
      subject.result.must_equal ""
      log.must_equal <<-STR.dent
        SKIP + Test
      STR
    end
    it "describes both a parent skip and its own skip" do
      parent = klass.new
      parent.run_mode = :skip
      subject.parent = parent
      subject.run_mode = :skip
      subject.execute
      subject.result.must_equal ""
      log.must_equal <<-STR.dent
        SKIP Test
      STR
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
        subject.result.must_equal "prepared"
        log.must_equal <<-STR.dent
          + Test
            preparing
        STR
      end
      it "logs destroy but does not execute" do
        subject.run_mode = :destroy
        subject.execute
        subject.result.must_equal "prepared"
        log.must_equal <<-STR.dent
          - Test
            preparing
        STR
      end
    end
  end

  describe "#create?" do

    it "is true when the run_mode is create" do
      subject.must_be :create?
      subject.run_mode = :destroy
      subject.wont_be :create?
    end
  end

  describe "#destroy?" do

    it "is true when the run_mode is destroy" do
      subject.wont_be :destroy?
      subject.run_mode = :destroy
      subject.must_be :destroy?
    end
  end
end
