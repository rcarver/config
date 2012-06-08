require 'helper'

describe Config::Cluster do

  describe ".from_string" do

    it "works" do
      cluster = Config::Cluster.from_string("sample", <<-STR)
        configure :foo,
          value: "ok"
      STR
      cluster.to_s.must_equal "sample cluster"
      cluster.configuration.foo.value.must_equal "ok"
    end

    it "provides useful information for a syntax error" do
      file = __FILE__
      line = __LINE__ + 2 # why is this 2? 3 makes more sense to me.
      begin
        Config::Cluster.from_string("sample", <<-STR, __FILE__, __LINE__)
          xconfigure :foo,
            value: "ok"
        STR
      rescue => e
        e.class.must_equal NoMethodError
        e.message.must_equal %(undefined method `xconfigure' for <Cluster>:Config::DSL::ClusterDSL)
        e.backtrace.first.must_equal "#{file}:#{line}:in `from_string'"
      end
    end
  end
end

describe "filesystem", Config::Cluster do

  describe ".from_file" do

    let(:file) { tmpdir + "sample.rb" }

    it "works" do
      file.open("w") do |f|
        f.puts "configure :foo,"
        f.puts "  value: \"ok\""
      end
      cluster = Config::Cluster.from_file(file)
      cluster.to_s.must_equal "sample cluster"
      cluster.configuration.foo.value.must_equal "ok"
    end

    it "provides useful information for an error" do
      file.open("w") do |f|
        f.puts "# the first line"
        f.puts "xconfigure :foo,"
        f.puts "  value: \"ok\""
      end
      begin
        Config::Cluster.from_file(file)
      rescue => e
        e.class.must_equal NoMethodError
        e.message.must_equal %(undefined method `xconfigure' for <Cluster>:Config::DSL::ClusterDSL)
        e.backtrace.first.must_equal "#{file}:2:in `from_string'"
      end
    end
  end
end

