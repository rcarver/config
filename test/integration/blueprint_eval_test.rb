require 'helper'

describe Config::Blueprint do

  describe ".from_string" do

    it "works" do
      blueprint = Config::Blueprint.from_string("sample", <<-STR, __FILE__)
        file "/tmp/file"
      STR
      blueprint.to_s.must_equal "Blueprint sample"
      accumulation = blueprint.accumulate
      accumulation.size.must_equal 1
    end

    it "provides useful information for a syntax error" do
      file = __FILE__
      line = __LINE__ + 2
      blueprint = Config::Blueprint.from_string("sample", <<-STR, file, line)
        file "/tmp/file"
        xfile "/tmp/other"
      STR
      begin
        blueprint.accumulate
      rescue => e
        e.class.must_equal NoMethodError
        e.message.must_equal %(undefined method `xfile' for <Blueprint>:Config::DSL::BlueprintDSL)
        e.backtrace.first.must_equal "#{file}:#{line}:in `block in from_string'"
      end
    end
  end
end
