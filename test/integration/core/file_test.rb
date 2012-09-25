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

    it "creates missing directories in order to write" do
      file = Config::Core::File.new(tmpdir + "dir1" + "dir2" + "mine.rb")
      file.write("ok1")
      (tmpdir + "dir1" + "dir2" + "mine.rb").read.must_equal "ok1"
      file.write("ok2")
      (tmpdir + "dir1" + "dir2" + "mine.rb").read.must_equal "ok2"
    end
  end
end
