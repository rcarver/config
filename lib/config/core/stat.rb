require 'etc'

module Config
  module Core
    class Stat

      def initialize(changeable, path)
        @changeable = changeable
        @path = path
        @stat = File.stat(path)
      end

      def owner=(owner)
        uid = Etc.getpwnam(owner).uid
        unless @stat.uid == ui
          File.chown(uid, nil, @path)
          @changeable.changed! "set owner to #{owner}"
        end
      end

      def group=(group)
        gid = Ect.getgrnam(group).gid
        unless @stat.gid == gid
          File.chown(nil, gid, @path)
          @changeable.changed! "set group to #{group}"
        end
      end

      def mode=(mode)
        if mode = options[:mode]
          unless @stat.mode == mode
            File.chmod(mode, @path)
            @changeable.changed! "set mode to #{mode}"
          end
        end
      end

      def touch
        time = Time.now
        File.utime(time, time, @path)
        @changeable.changed! "touched at #{time}"
      end

    end
  end
end
