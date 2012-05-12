module Config
  module Data
    # A very simple git client. I have chosen to implement my own client
    # rather than use an existing library in order to 1) reduce
    # dependencies, 2) provide complete clarity on how the data repo is
    # maintained.
    class Repo

      StateError  = Class.new(RuntimeError)
      CommitError = Class.new(StateError)
      PushError   = Class.new(StateError)

      class Cmd

        Failure = Class.new(RuntimeError)

        def initialize(dir)
          @dir = dir
        end

        def run(command)
          ::Dir.chdir(@dir) {
            out, s = Open3.capture2e(command)
            raise Failure, out unless s.exitstatus == 0
          }
        end
      end

      def initialize(dir, name)
        @dir = dir
        @name = name
        @path = Pathname.new(@dir) + name
        @clone = Cmd.new(@dir)
        @git = Cmd.new(@path)
      end

      attr :path

      attr_writer :git
      attr_writer :clone

      # Clone a git repo.
      #
      # url - String url to clone.
      #
      # Returns nothing.
      def clone(url)
        @clone.run "git clone #{url} #{@name}"
      end

      # Pull from origin. Performs a pull with rebase to minimize merge
      # noise.
      #
      # Returns nothing.
      def pull
        @git.run "git pull --rebase"
      end

      # Add files to the index.
      #
      # Returns nothing.
      def add(path)
        @git.run "git add #{path}"
      end

      # Remove files from the index.
      #
      # Returns nothing.
      def rm(path)
        @git.run "git rm #{path}"
      end

      # Reset the index. Does a hard reset to ensure a clean slate.
      #
      # Returns nothing.
      def reset
        @git.run "git reset --hard"
      end

      # Commit a change.
      #
      # Returns nothing.
      # Raises CommitError if there is a problem, most likely that there
      # is nothing to commit.
      def commit(msg)
        begin
          @git.run "git commit -m '#{msg}'"
        rescue Cmd::Failure => e
          raise CommitError, e.message
        end
      end

      # Push commits to the origin.
      #
      # Returns nothing.
      # Raises PushError if there is a problem, most likely that there
      # are changes to pull.
      def push
        begin
          @git.run "git push origin HEAD"
        rescue Cmd::Failure => e
          raise PushError, e.message
        end
      end

    end
  end
end
