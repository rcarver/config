module Config
  module Patterns

    autoload :Directory, 'config/patterns/directory'
    autoload :File, 'config/patterns/file'

    def file(path)
      add Config::Patterns::File do |p|
        p.path = path
        yield p if block_given?
      end
    end

    def dir(path, &block)
      add Config::Patterns::Directory do |p|
        p.path = path
        yield p if block_given?
      end
    end
  end
end
