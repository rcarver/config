require 'helper'

describe "filesystem", Config::ProjectData do

  subject { Config::ProjectData.new(tmpdir) }

  it "can read a secret" do
    (tmpdir + "secret-default").open("w") do |f|
      f.print "shh"
    end
    subject.secret(:default).read.must_equal "shh"
  end

end


