require 'helper'

describe Config::Global do

  describe ".from_string" do

    it "works" do
      cluster = Config::Global.from_string(<<-STR, __FILE__)
        configure :foo,
          value: "ok"
      STR
      cluster.configuration.foo.value.must_equal "ok"
    end

    it "provides useful information for a syntax error" do
      file = __FILE__
      line = __LINE__ + 2
      begin
        Config::Global.from_string(<<-STR, file, line)
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

