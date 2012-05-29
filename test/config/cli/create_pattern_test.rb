require 'helper'

describe Config::CLI::CreatePattern do

  subject { Config::CLI::CreatePattern }

  specify "#usage" do
    cli.usage.must_equal "test-command [<topic/name>] OR [<topic> <name>]"
  end

  describe "#parse" do
    it "gets the name from two different args" do
      cli.parse! %w(abc def)
      cli.topic_name.must_equal "abc"
      cli.pattern_name.must_equal "def"
    end
    it "gets the name from one arg if it includes a slash" do
      cli.parse! %w(abc/def)
      cli.topic_name.must_equal "abc"
      cli.pattern_name.must_equal "def"
    end
    describe "fail if both parts can't be found in the one arg" do
      specify "slash at end" do
        expect_fail_with_usage { cli.parse! %w(abc/) }
      end
      specify "slash at front" do
        expect_fail_with_usage { cli.parse! %w(/abc) }
      end
      specify "no slash" do
        expect_fail_with_usage { cli.parse! %w(abc) }
      end
    end
    it "fails if no args are given" do
      expect_fail_with_usage { cli.parse! }
    end
  end

  describe "#execute" do
    it "executes a blueprint" do
      cli.topic_name = "a"
      cli.pattern_name = "b"

      cli.execute

      topics = cli.find_blueprints(Config::Meta::PatternTopic)
      topics.size.must_equal 1
      topics[0].name.must_equal "a"

      patterns = cli.find_blueprints(Config::Meta::Pattern)
      patterns.size.must_equal 1
      patterns[0].name.must_equal "b"
    end
  end
end

