module Config
  module Patterns
    class Directory < Config::Pattern

      desc "The full path of the directory"
      key :path

      desc "The user that owns the directory"
      attr :owner, nil

      desc "The group that owns the directory"
      attr :group, nil

      desc "The octal mode of the directory, such as 0755"
      attr :mode, nil

      def describe
        "Directory #{pn}"
      end

      def call
        if owner || group
          add Config::Patterns::Chown do |p|
            p.path = path
            p.owner = owner
            p.group = group
          end
        end
      end

      def create
        unless pn.exist?
          pn.mkdir
          changes << "created"
        end

        #stat = Config::Core::Stat.new(self, path)
        #stat.owner = owner if owner
        #stat.group = group if group
        #stat.mode = mode if mode
        #stat.touch if touch
      end

      def destroy
        if pn.exist?
          pn.rmtree
          changes << "deleted"
        end
      end

    protected

      def pn
        @pn ||= Pathname.new(path).cleanpath
      end

    end
  end
end
