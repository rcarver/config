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

    let(:blueprint_name) { :webserver }

    subject { Config::Blueprint.from_string(blueprint_name, code, __FILE__) }

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
        subject.to_s.must_equal "Blueprint webserver"
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
Accumulate Blueprint webserver
  + BlueprintTest::Test
    [BlueprintTest::Test name:"one"]
  + BlueprintTest::Test
    [BlueprintTest::Test name:"two"]
Validate Blueprint webserver
Resolve Blueprint webserver
Execute Blueprint webserver
  + [BlueprintTest::Test name:"one"]
  + [BlueprintTest::Test name:"two"]
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
Accumulate Blueprint webserver
  + BlueprintTest::Test
    [BlueprintTest::Test name:"the test"]
Validate Blueprint webserver
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
Accumulate Blueprint webserver
  + BlueprintTest::Test
    [BlueprintTest::Test name:"the test"]
  + BlueprintTest::Test
    [BlueprintTest::Test name:"the test"]
Validate Blueprint webserver
Resolve Blueprint webserver
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
Accumulate Blueprint webserver
  + BlueprintTest::Test
    [BlueprintTest::Test name:"the test"]
  + BlueprintTest::Test
    [BlueprintTest::Test name:"the test"]
Validate Blueprint webserver
Resolve Blueprint webserver
Execute Blueprint webserver
  + [BlueprintTest::Test name:"the test"]
  SKIP [BlueprintTest::Test name:"the test"]
        STR
      end
    end

    describe "using top level variables" do

      let(:code) {
        <<-STR
          add BlueprintTest::Test do |t|
            t.name = node.ip_address
            t.value = cluster.name
          end
          add BlueprintTest::Test do |t|
            t.name = "another"
            t.value = configure.sample.value
          end
        STR
      }

      let(:facts) { Config::Core::Facts.new("ip_address" => "192.0.0.1") }
      let(:cluster) { Config::Cluster.new("prod") }
      let(:nodes) { MiniTest::Mock.new }
      let(:configuration) { Config::Configuration.new }

      before do
        cluster_context = Config::ClusterContext.new(cluster, nodes)
        configuration.set_group(:sample, value: 123)

        subject.facts = facts
        subject.configuration = Config::Configuration.merge(configuration)
        subject.cluster_context = cluster_context
      end

      it "executes the patterns" do
        subject.execute
        BlueprintTest.value.must_equal [
          [:create, "192.0.0.1", "prod"],
          [:create, "another", 123]
        ]
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

      let(:previous) { Config::Blueprint.from_string("previous #{blueprint_name}", previous_code, __FILE__) }
      subject        { Config::Blueprint.from_string("current #{blueprint_name}", current_code, __FILE__) }

      before do
        subject.previous_accumulation = previous.accumulate
      end

      it "destroys the removed pattern" do
        subject.execute
        BlueprintTest.value.must_equal [
          [:destroy, "pattern1", "ok"],
          [:create, "pattern2", "ok"],
          [:create, "pattern3", "new"]
        ]
      end

      it "logs what happened" do
        log_execute.must_equal <<-STR
Accumulate Blueprint previous webserver
  + BlueprintTest::Test
    [BlueprintTest::Test name:"pattern1"]
  + BlueprintTest::Test
    [BlueprintTest::Test name:"pattern2"]
  + BlueprintTest::Test
    [BlueprintTest::Test name:"pattern3"]
Accumulate Blueprint current webserver
  + BlueprintTest::Test
    [BlueprintTest::Test name:"pattern2"]
  + BlueprintTest::Test
    [BlueprintTest::Test name:"pattern3"]
Validate Blueprint current webserver
Resolve Blueprint current webserver
Execute Blueprint current webserver
  - [BlueprintTest::Test name:"pattern1"]
  + [BlueprintTest::Test name:"pattern2"]
  + [BlueprintTest::Test name:"pattern3"]
        STR
      end
    end

    describe "with a configuration" do

      let(:code) {
        <<-STR
          add BlueprintTest::Test do |t|
            t.name = configure.webserver.my_name
            t.value = "ok"
          end
        STR
      }

      let(:configuration) { Config::Configuration.new("cfg") }

      before do
        configuration.set_group(:webserver, my_name: "bob")
        subject.configuration = Config::Configuration.merge(configuration)
      end

      it "can use configuration variables" do
        subject.execute
        BlueprintTest.value.must_equal [
          [:create, "bob", "ok"]
        ]
      end

      it "logs when variables are used" do
        log_execute.must_equal <<-STR
Accumulate Blueprint webserver
  + BlueprintTest::Test
      Read webserver.my_name => "bob" from cfg
    [BlueprintTest::Test name:"bob"]
Validate Blueprint webserver
Resolve Blueprint webserver
Execute Blueprint webserver
  + [BlueprintTest::Test name:"bob"]
        STR
      end
    end
  end
end
