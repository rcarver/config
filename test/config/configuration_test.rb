require 'helper'

describe Config::Configuration do

  specify ".new" do
    Config::Configuration.new.must_be_instance_of Levels::Level
  end

  specify ".merge" do
    Config::Configuration.merge([]).must_be_instance_of Levels::Merged
  end

  describe "logging" do

    let(:level1) {
      level = Config::Configuration.new("l1")
      level.set_group(:sample, a: 1, b: 2)
      level
    }

    let(:level2) {
      level = Config::Configuration.new("l2")
      level.set_group(:sample, a: 9, c: 3)
      level.set_group(:recursive, x: -> { [sample.a, sample.b] })
      level
    }

    subject { Config::Configuration.merge(level1, level2) }

    it "logs when a single-level, top level variable is used" do
      subject.sample.b
      log_string.must_equal <<-STR.dent
        Read sample.b => 2 from l1
      STR
    end

    it "logs when a single-level, lower level variable is used" do
      subject.sample.c
      log_string.must_equal <<-STR.dent
        Read sample.c => 3 from l2
      STR
    end

    it "logs when a multi-level variable is used" do
      subject.sample.a
      log_string.must_equal <<-STR.dent
        Read sample.a
          Skip 1 from l1
          Use  9 from l2
      STR
    end

    it "logs a recursive value" do
      subject.recursive.x
      log_string.must_equal <<-STR.dent
        Read recursive.x
            Read sample.a
              Skip 1 from l1
              Use  9 from l2
            Read sample.b
              Use  2 from l1
          Use  [9, 2] from l2
      STR
    end
  end
end
