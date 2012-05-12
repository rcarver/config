module Config
  module Data
    class GitDatabase

      def initialize(path, repo)
        @path = path
        @repo = repo
      end

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

      def txn
        @repo.reset_hard
        yield
        begin
          @repo.push
        rescue Config::Data::Repo::PushError
          @repo.pull_rebase
          retry
        end
      end

    end
  end
end

