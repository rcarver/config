require 'helper'

module BlueprintTest

  class << self
    attr_accessor :value
  end

  # A pattern that sets a variable.
  class Test < Config::Pattern
    desc "The name"
    key  :name
    desc "The value"
    attr :value
    def create
      BlueprintTest.value << [:create, name, value]
    end
    def destroy
      BlueprintTest.value << [:destroy, name, value]
    end
  end

  describe Config::Blueprint do

    before do
      BlueprintTest.value = []
    end

    let(:blueprint_name) { "test" }

    subject { Config::Blueprint.from_string(blueprint_name, code) }

    def log_execute(*args)
      begin
        subject.execute(*args)
      rescue
        # ignore
      end
      log_string
    end

    describe "in general" do

      let(:code) {
        <<-STR
          add BlueprintTest::Test do |t|
            t.name = "one"
            t.value = 1
          end
          add BlueprintTest::Test do |t|
            t.name = "two"
            t.value = 2
          end
        STR
      }

      it "has a name" do
        subject.to_s.must_equal "Blueprint test"
      end

      it "accumulates the patterns" do
        accumulation = subject.accumulate
        accumulation.size.must_equal 2
      end

      it "executes the patterns" do
        subject.validate
        BlueprintTest.value.must_equal []
        subject.execute
        BlueprintTest.value.must_equal [
          [:create, "one", 1],
          [:create, "two", 2]
        ]
      end

      it "logs what happened" do
        log_execute.must_equal <<-STR
Accumulate Blueprint test
  Add BlueprintTest::Test
    > [BlueprintTest::Test name:"one"]
  Add BlueprintTest::Test
    > [BlueprintTest::Test name:"two"]
Validate Blueprint test
Resolve Blueprint test
Execute Blueprint test
  Create [BlueprintTest::Test name:"one"]
  Create [BlueprintTest::Test name:"two"]
        STR
      end
    end

    describe "with invalid patterns" do

      let(:code) {
        <<-STR
          add BlueprintTest::Test do |t|
            t.name = "the test"
            # no value set
          end
        STR
      }

      it "detects validation errors" do
        subject.accumulate
        proc { subject.validate }.must_raise Config::Core::ValidationError
      end

      it "logs what happened" do
        log_execute.must_equal <<-STR
Accumulate Blueprint test
  Add BlueprintTest::Test
    > [BlueprintTest::Test name:"the test"]
Validate Blueprint test
  ERROR [BlueprintTest::Test name:"the test"] missing value for :value (The value)
        STR
      end
    end

    describe "with conflicting patterns" do

      let(:code) {
        <<-STR
          add BlueprintTest::Test do |t|
            t.name = "the test"
            t.value = 1
          end
          add BlueprintTest::Test do |t|
            t.name = "the test"
            t.value = 2
          end
        STR
      }

      it "detects conflict errors" do
        proc { subject.validate }.must_raise Config::Core::ConflictError
      end

      it "logs what happened" do
        log_execute.must_equal <<-STR
Accumulate Blueprint test
  Add BlueprintTest::Test
    > [BlueprintTest::Test name:"the test"]
  Add BlueprintTest::Test
    > [BlueprintTest::Test name:"the test"]
Validate Blueprint test
Resolve Blueprint test
  CONFLICT [BlueprintTest::Test name:"the test"] {:name=>"the test", :value=>1} vs. [BlueprintTest::Test name:"the test"] {:name=>"the test", :value=>2}
        STR
      end
    end

    describe "with duplicate patterns" do

      let(:code) {
        <<-STR
          add BlueprintTest::Test do |t|
            t.name = "the test"
            t.value = "ok"
          end
          add BlueprintTest::Test do |t|
            t.name = "the test"
            t.value = "ok"
          end
        STR
      }

      it "only runs one pattern" do
        subject.validate
        BlueprintTest.value.must_equal []
        subject.execute
        BlueprintTest.value.must_equal [
          [:create, "the test", "ok"]
        ]
      end

      it "logs what happened" do
        log_execute.must_equal <<-STR
Accumulate Blueprint test
  Add BlueprintTest::Test
    > [BlueprintTest::Test name:"the test"]
  Add BlueprintTest::Test
    > [BlueprintTest::Test name:"the test"]
Validate Blueprint test
Resolve Blueprint test
Execute Blueprint test
  Create [BlueprintTest::Test name:"the test"]
  Skip [BlueprintTest::Test name:"the test"]
        STR
      end
    end

    describe "with a previous accumulation" do

      # Previously we ran three simple patterns.
      let(:previous_code) {
        <<-STR
          add BlueprintTest::Test do |t|
            t.name = "pattern1"
            t.value = "ok"
          end
          add BlueprintTest::Test do |t|
            t.name = "pattern2"
            t.value = "ok"
          end
          add BlueprintTest::Test do |t|
            t.name = "pattern3"
            t.value = "ok"
          end
        STR
      }

      # Now we run again with changed patterns.
      #
      # pattern1 is missing so it's destroyed.
      # pattern2 is the same so it gets run again.
      # pattern3 is changed and the new version is run.
      let(:current_code) {
        <<-STR
          add BlueprintTest::Test do |t|
            t.name = "pattern2"
            t.value = "ok"
          end
          add BlueprintTest::Test do |t|
            t.name = "pattern3"
            t.value = "new"
          end
        STR
      }

      let(:previous) { Config::Blueprint.from_string("previous test", previous_code) }
      subject        { Config::Blueprint.from_string("test", current_code) }

      before do
        @accumulation = previous.accumulate
      end

      it "destroys the removed pattern" do
        subject.execute(@accumulation)
        BlueprintTest.value.must_equal [
          [:destroy, "pattern1", "ok"],
          [:create, "pattern2", "ok"],
          [:create, "pattern3", "new"]
        ]
      end

      it "logs what happened" do
        log_execute(@accumulation).must_equal <<-STR
Accumulate Blueprint previous test
  Add BlueprintTest::Test
    > [BlueprintTest::Test name:"pattern1"]
  Add BlueprintTest::Test
    > [BlueprintTest::Test name:"pattern2"]
  Add BlueprintTest::Test
    > [BlueprintTest::Test name:"pattern3"]
Accumulate Blueprint test
  Add BlueprintTest::Test
    > [BlueprintTest::Test name:"pattern2"]
  Add BlueprintTest::Test
    > [BlueprintTest::Test name:"pattern3"]
Validate Blueprint test
Resolve Blueprint test
Execute Blueprint test
  Destroy [BlueprintTest::Test name:"pattern1"]
  Create [BlueprintTest::Test name:"pattern2"]
  Create [BlueprintTest::Test name:"pattern3"]
        STR
      end
    end

    describe "with a cluster" do

      let(:cluster_code) {
        <<-STR
          blueprint :webserver,
            my_name: "bob"
        STR
      }

      let(:code) {
        <<-STR
          add BlueprintTest::Test do |t|
            t.name = cluster.webserver.my_name
            t.value = "ok"
          end
        STR
      }

      let(:blueprint_name) { "webserver" }
      let(:cluster) { Config::Cluster.from_string("staging", cluster_code) }

      before do
        subject.cluster = cluster
      end

      it "can use cluster variables" do
        subject.execute
        BlueprintTest.value.must_equal [
          [:create, "bob", "ok"]
        ]
      end

      it "logs when variables are used" do
        log_execute.must_equal <<-STR
Accumulate Blueprint webserver
  Add BlueprintTest::Test
      [Variables "Blueprint webserver"] read :my_name
    > [BlueprintTest::Test name:"bob"]
Validate Blueprint webserver
Resolve Blueprint webserver
Execute Blueprint webserver
  Create [BlueprintTest::Test name:"bob"]
        STR
      end
    end
  end
end
