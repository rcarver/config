require 'helper'

module MarshallTest

  class TestPattern
    include Config::Core::Marshalable
    include Config::Core::Attributes
    attr :name
    attr :value
  end

  describe Config::Core::Marshalable do
    it "can marshall and unmarshall" do
      pattern = TestPattern.new
      pattern.name = "the name"
      pattern.value = "the value"

      dump = Marshal.dump(pattern)

      restore = Marshal.load(dump)
      restore.class.must_equal TestPattern
      restore.name.must_equal "the name"
      restore.value.must_equal "the value"
    end
  end
end

