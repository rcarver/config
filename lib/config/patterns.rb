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

    # Public: Add a file.
    #
    # path - String path of the file.
    #
    def file(path)
      add Config::Patterns::File do |p|
        p.path = path
        yield p if block_given?
      end
    end

    # Public: Add a directory.
    #
    # path - String path of the directory.
    #
    def dir(path, &block)
      add Config::Patterns::Directory do |p|
        p.path = path
        yield p if block_given?
      end
    end

    # Autoload builtin patterns.

    autoload :Directory, 'config/patterns/directory'
    autoload :File, 'config/patterns/file'
  end
end
