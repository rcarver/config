module Config
  module Data
    class GitDatabase

      def initialize(path, repo)
        @path = path
        @repo = repo
      end

      # Store information about a node in the database.
      #
      # node - Config::Node.
      #
      # Returns nothing.
      def update_node(node)
        file = facts_file(node)
        status = file.exist? ? "Updated" : "Added"

        txn do
          (@path + "facts").mkpath
          file.open("w") do |f|
            f.print node.facts.to_json
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
        return if !facts_file(node).exist?

        txn do
          @repo.rm facts_file(node)
          @repo.commit "Removed node #{node.fqn}"
        end
      end

    protected

      def facts_file(node)
        @path + "facts/#{node.fqn}.json"
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
        rescue Config::Data::Repo::PushError => e
          @repo.pull_rebase
          # NOTE: We should determine if retries should be slower
          # or if a backoff strategy should be designed.
          retry
        end
      end

    end
  end
end

