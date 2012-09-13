require 'etc'
require 'fileutils'

module Config
  module Patterns
    class Chown < Config::Pattern

      desc "The path to modify"
      key :path

      desc "The owner of the path"
      attr :owner, nil

      desc "The group of the path"
      attr :group, nil

      desc "Operate recursively"
      attr :recursive, false

      def describe
        chown = [owner, group].compact.join(":")
        recurse = "(recursive)" if recursive
        ["Chown", path, "to", chown, recurse].compact.join(" ")
      end

      def create
        stat = ::File.stat(path)

        if owner
          uid = ::Etc.getpwnam(owner).uid
          unless stat.uid == uid
            chown(uid, nil)
            changes << "set owner"
            log << log.colorize("Set owner to #{owner}", :brown)
          end
        end

        if group
          gid = ::Etc.getgrnam(group).gid
          unless stat.gid == gid
            chown(nil, gid)
            changes << "set group"
            log << log.colorize("Set group to #{group}", :brown)
          end
        end
      end

      # Dependency injection for testing.
      attr_writer :fu

    protected

      def fu
        @fu ||= ::FileUtils
      end

      def chown(uid, gid)
        if recursive
          fu.chown_R(uid, gid, path)
        else
          fu.chown(uid, gid, path)
        end
      end

    end
  end
end
