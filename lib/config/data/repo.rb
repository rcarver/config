module Config
  module Data
    class Repo

      def initialize(dir, name)
        @dir = dir
        @name = name
        @path = Pathname.new(@dir) + name
        @clone = Config::Core::Cmd.new(@dir)
        @git = Config::Core::Cmd.new(@path)
      end

      attr :path

      attr_writer :git
      attr_writer :clone

      def clone(url)
        @clone.run "git clone #{url} #{@name}"
      end

      def reset
        @git.run "git reset --hard"
      end

      def pull
        @git.run "git pull"
      end

      def add(path)
        @git.run "git add #{path}"
      end

      def rm(path)
        @git.run "git rm #{path}"
      end

      def commit(msg)
        @git.run "git commit -m '#{msg}'"
      end

    end
  end
end
