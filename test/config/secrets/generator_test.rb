require 'helper'

describe Config::Secrets::Generator do

  subject { Config::Secrets::Generator.new }

  before do
    subject.hash_function = :sha
    subject.iterations = 1
    subject.key_length = 128
  end

  it "generates a key" do
    key = subject.generate_key("shh", "123")
    key.must_equal <<-STR
fdcUSkMJyF4Q+F3FDMpyCGiQD77lY+FabOJWi7VE8RwJCUioS1FHsnISKhUG
m4KvcCbc5rW0/oCeYvyzaN42m1D7miCFMX3lHOPtod8m95PIWHQ8f0oB80ut
qjdAgUSCe7dYM4QTLwGDaT+tkFLs6Xn10Y7evL7/lsj6iQhsxS4=
     STR
  end
end

