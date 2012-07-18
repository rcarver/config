require 'helper'

describe "filesystem", Config::Core::File do

  subject { Config::Core::File.new(tmpdir + "mine.rb") }

  specify "#path" do
    subject.path.must_equal (tmpdir + "mine.rb").to_s
  end

  specify "#name" do
    subject.name.must_equal "mine.rb"
  end

  specify "#basename" do
    subject.basename.must_equal "mine"
  end

  describe "#read" do
    it "returns nil if nothing exists" do 
      subject.read.must_equal nil
    end
    it "returns the file contents" do
      (tmpdir + "mine.rb").open("w") do |f|
        f.print "ok"
      end
      subject.read.must_equal "ok"
    end
  end

  describe "#write" do
    it "writes the file" do
      subject.write("ok")
      (tmpdir + "mine.rb").read.must_equal "ok"
    end
  end
end
