module Config
  module Core
    # A very simple git client. I have chosen to implement my own client
    # rather than use an existing library in order to 1) reduce
    # dependencies, 2) provide complete clarity on how the data repo is
    # maintained.
    class GitRepo

      StateError  = Class.new(RuntimeError)
      CommitError = Class.new(StateError)
      PushError   = Class.new(StateError)

      class Cmd

        Failure = Class.new(RuntimeError)

        def initialize(dir)
          @dir = dir
        end

        def run(command)
          out, status = exec(command)
          raise Failure, out unless status.exitstatus == 0
          return out, status
        end

        def status?(expected_exitstatus = 0, command)
          out, status = exec(command)
          status.exitstatus == expected_exitstatus
        end

      protected

        def exec(command)
          out, status = nil
          ::Dir.chdir(@dir) {
            out, status = Open3.capture2e(command)
          }
          return out, status
        end
      end

      def initialize(path)
        @path = path
        @git = Cmd.new(@path)
      end

      # Path to the checkout.
      #
      # Returns a String.
      def path
        @path.to_s
      end

      # Describe the current head commit.
      #
      # Returns String, String. The first string is a 7 character SHA of
      # the commit. The second string is the one line commit message.
      def describe_head
        out, status = @git.run("git log --oneline | head -n1")
        line = out.chomp
        sha = line[/^([0-9a-z]+)/, 1]
        message = line[/^.*?\s(.*)$/, 1]
        return sha, message
      end

      # Determine if the repository is in a clean state. A clean state
      # is no modified files and no untracked files.
      #
      # Returns a Boolean.
      def clean_status?
        @git.status?(0, "test -z \"$(git status --porcelain)\"")
      end

      # Pull from origin. Performs a pull with rebase to minimize merge
      # noise.
      #
      # Returns nothing.
      def pull_rebase
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
      def reset_hard
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
