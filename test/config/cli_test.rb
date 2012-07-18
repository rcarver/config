require 'helper'

describe Config::CLI do

  # TODO: alter support/cli_spec. so we can use it for this test instead of
  # duplicating this setup.

  let(:stdin) { StringIO.new }
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }
  let(:argv) { [] }
  let(:env) { Hash.new }

  let(:cli) { subject.new("test-command", stdin, stdout, stderr) }

  describe "#run" do

    describe "cleaning the runtime environment" do

      let(:cli_class) do
        Class.new(Config::CLI::Base) do
          attr_reader :env_keys, :env_path
          attr_accessor :raise_error
          def execute
            @env_keys = ::ENV.keys
            @env_path = ::ENV['PATH']
            raise "ack" if raise_error
          end
        end
      end

      subject { cli_class }

      describe "Bundler" do

        def bundler_keys(keys)
          keys.find_all { |k| k =~ /^BUNDLE_/ }
        end

        specify "bundler exists" do
          bundler_keys(ENV.keys).wont_be_empty
        end

        it "removes Bundler" do
          cli.run(argv, env)
          bundler_keys(cli.env_keys).must_be_empty
        end

        it "restores bundler" do
          cli.run(argv, env)
          bundler_keys(ENV.keys).wont_be_empty
        end

        it "restores bundler if an error occurs" do
          cli.raise_error = true
          proc { cli.run(argv, env) }.must_raise RuntimeError
          bundler_keys(ENV.keys).wont_be_empty
        end
      end

      describe "PATH" do

        before do
          @original_path = ENV['PATH']
          @altered_path = "a:#{@original_path}:b"
          ENV['PATH'] = @altered_path
          ENV[Config::CLI::CONFIG_PATH_ADDITIONS] = "a:b"
        end

        after do
          ENV.delete Config::CLI::CONFIG_PATH_ADDITIONS
          ENV['PATH'] = @original_path
        end

        it "removes config additions" do
          cli.run(argv, env)
          cli.env_path.must_equal @original_path
        end

        it "restores config additions" do
          cli.run(argv, env)
          ENV['PATH'].must_equal @altered_path
        end

        it "restores config additions on error" do
          cli.raise_error = true
          proc { cli.run(argv, env) }.must_raise RuntimeError
          ENV['PATH'].must_equal @altered_path
        end
      end
    end
  end
end
