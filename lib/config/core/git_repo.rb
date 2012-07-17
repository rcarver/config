module Config
  module Core
    # A very simple git client. I have chosen to implement my own client
    # rather than use an existing library in order to 1) reduce
    # dependencies, 2) provide complete clarity on how the data repo is
    # maintained.
    class GitRepo

      PushError = Class.new(RuntimeError)

      class CLI

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
        @cli = CLI.new(@path)
      end

      # Determine if there are any commits in the remote repository.
      #
      # Returns a Boolean.
      def has_remote_commits?
        @cli.run "git fetch origin"
        @cli.status?(0, "git rev-list --quiet origin/master")
      end

      # Determine if there are any commits in the current, local
      # repository.
      #
      # Returns a Boolean.
      def has_local_commits?
        @cli.status?(0, "git rev-list --quiet master")
      end

      # Describe the current head commit.
      #
      # Returns [String, String]. The first string is a 7 character SHA
      # of the commit. The second string is the one line commit message.
      def describe_head
        return "0000000", "" unless has_local_commits?

        out, status = @cli.run("git log --oneline | head -n1")
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
        @cli.status?(0, "test -z \"$(git status --porcelain)\"")
      end

      # Pull from origin. Performs a pull with rebase to minimize merge
      # noise.
      #
      # Returns nothing.
      def pull_rebase
        if has_remote_commits?
          @cli.run "git pull --rebase"
        end
      end

      # Add files to the index.
      #
      # Returns nothing.
      def add(path)
        @cli.run "git add #{path}"
      end

      # Remove files from the index.
      #
      # Returns nothing.
      def rm(path)
        @cli.run "git rm #{path}"
      end

      # Reset the index. Does a hard reset to ensure a clean state on
      # the local copy.
      #
      # Returns nothing.
      def reset_hard
        if has_local_commits?
          @cli.run "git reset --hard"
        end
      end

      # Commit a change.
      #
      # Returns nothing.
      def commit(msg)
        dirty = @cli.status?(0, "git status --porcelain | grep '^[MARD]'")
        if dirty
          @cli.run "git commit -m '#{msg}'"
        end
      end

      # Push commits to the origin.
      #
      # Returns nothing.
      # Raises PushError if there is a problem, most likely that there
      # are changes to pull.
      def push
        begin
          @cli.run "git push origin HEAD"
        rescue CLI::Failure => e
          raise PushError, e.message
        end
      end

    end
  end
end
