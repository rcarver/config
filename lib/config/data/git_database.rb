module Config
  module Data
    class Repo

      def initialize(path, repo)
        @path = path
        @repo = repo
      end

      def update_node(node)
        @repo.reset
        @repo.pull
        facts_file(node).mkdir
        facts_file(node).open("w") do |f|
          f.print node.facts.to_json
        end
        @repo.add facts_file(node)
        @repo.commit "Updated #{node.fqn}"
        @repo.push
      end

      def remove_node(node)
        @repo.reset
        @repo.pull
        @repo.rm facts_file(node)
        @repo.commit "Removed #{node.fqn}"
        @repo.push
      end

      def facts_file(node)
        @path + "facts/#{node.fqn}.json"
      end

    end
  end
end

