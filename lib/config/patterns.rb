module Config
  module Patterns

    autoload :Directory, 'config/patterns/directory'
    autoload :File, 'config/patterns/file'

    def file(path)
      add Config::Patterns::File do |f|
        f.path = path
        yield f
      end
    end

    def dir(path, &block)
      add Config::Patterns::Directory do |d|
        d.path = path
        block.call(d)
      end
    end

    def dirp(path, &block)
      add Config::Patterns::Directory do |d|
        d.path = path
        d.recursive = true
        block.call(d)
      end
    end
  end
end
