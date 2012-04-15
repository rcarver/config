require 'helper'

describe Config::Blueprint do

  describe ".from_string" do

    it "works" do
      blueprint = Config::Blueprint.from_string("sample", <<-STR)
        file "/tmp/file"
      STR
      blueprint.to_s.must_equal "Blueprint sample"
      accumulation = blueprint.accumulate
      accumulation.size.must_equal 1
    end

    it "provides useful information for a syntax error" do
      file = __FILE__
      line = __LINE__ + 2
      blueprint = Config::Blueprint.from_string("sample", <<-STR, __FILE__, __LINE__)
        file "/tmp/file"
        xfile "/tmp/other"
      STR
      begin
        blueprint.accumulate
      rescue => e
        e.class.must_equal NoMethodError
        e.message.must_equal %(undefined method `xfile' for <Blueprint>:RbConfig::Blueprint::RootPattern)
        e.backtrace.first.must_equal "#{file}:#{line}:in `block in from_string'"
      end
    end
  end
end

describe "filesystem", Config::Blueprint do

  describe ".from_file" do

    let(:file) { tmpdir + "sample.rb" }

    it "works" do
      file.open("w") do |f|
        f.puts %(file "/tmp/file")
      end
      blueprint = Config::Blueprint.from_file(file)
      blueprint.to_s.must_equal "Blueprint sample"
      accumulation = blueprint.accumulate
      accumulation.size.must_equal 1
    end

    it "provides useful information for an error" do
      file.open("w") do |f|
        f.puts %(file "/tmp/file")
        f.puts %(xfile "/tmp/other")
      end
      blueprint = Config::Blueprint.from_file(file)
      begin
        blueprint.accumulate
      rescue => e
        e.class.must_equal NoMethodError
        e.message.must_equal %(undefined method `xfile' for <Blueprint>:RbConfig::Blueprint::RootPattern)
        e.backtrace.first.must_equal "#{file}:2:in `block in from_string'"
      end
    end
  end
end
