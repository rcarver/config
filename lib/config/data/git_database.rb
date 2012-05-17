module Config
  module Data
    class GitDatabase

      def initialize(path, repo)
        @path = Pathname.new(path)
        @repo = repo
      end

      # Update the state of the database.
      #
      # Returns nothing.
      def update
        @repo.reset_hard
        @repo.pull_rebase
      end

      # Get a node from the database.
      #
      # fqn - String the fully qualified node name.
      #
      # Returns a Config::Node.
      def find_node(fqn)
        file = node_file(fqn, false)
        if file.exist?
          json = JSON.parse(file.read)
          Config::Node.from_json(json)
        end
      end

      # Store information about a node in the database.
      #
      # node - Config::Node.
      #
      # Returns nothing.
      def update_node(node)
        file = node_file(node)
        status = file.exist? ? "Updated" : "Added"

        txn do
          (@path + "nodes").mkpath
          file.open("w") do |f|
            f.print JSON.generate(
              node.as_json,
              object_nl: "\n",
              indent: "  ",
              space: " "
            )
          end
          @repo.add file
          @repo.commit "#{status} node #{node.fqn}"
        end
      end

      # Remove information about a node from the databse.
      #
      # node - Config::Node.
      #
      # Returns nothing.
      def remove_node(node)
        return if !node_file(node).exist?

        txn do
          @repo.rm node_file(node)
          @repo.commit "Removed node #{node.fqn}"
        end
      end

    protected

      def node_file(node, is_node=true)
        fqn = is_node ? node.fqn : node
        @path + "nodes/#{fqn}.json"
      end

      # This is a critically important function. Here we make sure that changes
      # to the git repo are made cleanly and pushed to the origin.
      def txn
        # Do a hard reset on the repository to ensure a clean slate.
        @repo.reset_hard
        # The caller should make changes and commit them.
        yield
        begin
          # Attempt to push to the origin. If an error occurs,
          # pull from the origin and rebase our local changes.
          # Then try to push again.
          @repo.push
        rescue Config::Core::GitRepo::PushError => e
          @repo.pull_rebase
          # NOTE: We should determine if retries should be slower
          # or if a backoff strategy should be designed.
          retry
        end
      end

    end
  end
end

