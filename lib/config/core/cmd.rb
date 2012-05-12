module Config
  module Core
    class Cmd

      def initialize(dir)
        @dir = dir
      end

      def run(command)
        ::Dir.chdir(@dir) do
          `#{command}`
        end
      end
    end
  end
end
