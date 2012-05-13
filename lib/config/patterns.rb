module Config
  # This module provides helper methods for common patterns.
  # These helpers are available in Blueprints and Patterns.
  #
  # Examples
  #
  #     # Instead of this.
  #     add Config::Patterns::File do |f|
  #       f.path = "/tmp/file"
  #     end
  #
  #     # You can do this.
  #     file "/tmp/file"
  #
  #     # To configure more attributes, you can still use a block.
  #     file "/tmp/file" do |f|
  #       f.owner = "www"
  #     end
  #
  module Patterns

    class FileTemplate

      def initialize(pattern, context, source_file)
        @pattern = pattern
        @context = context
        pathname = Pathname.new(source_file)
        @templates = pathname.dirname + "templates"
      end

      def template=(file)
        @pattern.template_path = (@templates + file).to_s
        @pattern.template_context = @context
      end

      def method_missing(message, *args, &block)
        @pattern.public_send(message, *args, &block)
      end
    end

    # Public: Add a file.
    #
    # path - String path of the file.
    #
    # Yields a Patterns::FileTemplate which provides a simple
    # interface to using template files. Templates are stored in
    # `templates` directory next to your pattern class. You may use
    # any directory structure within `templates` or not. Other than
    # `templates=`, the yielded object behaves like a
    # Config::Patterns::File.
    #
    # Examples
    #
    #    # Evaluate `patterns/mine/templates/file.erb` in the
    #    # context of this class and write it to /tmp/file.
    #    class Mine::MyPattern < Config::Pattern
    #      def call
    #        file "/tmp/file" do |f|
    #          f.template = "file.erb"
    #        end
    #      end
    #    end
    #
    def file(path, simple_templating=true)
      if simple_templating
        caller_file = caller.first
      end
      add Config::Patterns::File do |p|
        p.path = path
        if block_given?
          if simple_templating
            yield FileTemplate.new(p, self, caller_file)
          else
            yield p
          end
        end
      end
    end

    # Public: Add a directory.
    #
    # path - String path of the directory.
    #
    # Yields a Config::Patterns::Directory.
    #
    def dir(path, &block)
      add Config::Patterns::Directory do |p|
        p.path = path
        yield p if block_given?
      end
    end

    # Public: Add a script.
    #
    # name - String name of the script.
    #
    # Yields a Config::Patterns::Script.
    #
    def script(name, &block)
      add Config::Patterns::Script do |p|
        p.name = name
        yield p if block_given?
      end
    end

    # Autoload builtin patterns.

    autoload :Directory, 'config/patterns/directory'
    autoload :File, 'config/patterns/file'
    autoload :Script, 'config/patterns/script'

  end
end
