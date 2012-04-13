require 'erb'

module Config
  class Template

    def initialize(path, options)
      @path = path
      @options = options
    end

    attr_reader :path

    def template
      # TODO: need path to template file.
      File.read()
    end

    def render
      ERB.new(template).evalulate(Vars.new(options[:vars] || {}))
    end

    def create
      new_content = render
      existing_content = File.read(path) if File.exist?(path)
      unless existing_content == new_content
        File.open(path) { |f| f.print new_content }
      end
    end

    def destroy
      File.rm(path) if File.exist?(path)
    end

    class Vars
      def initialize(vars)
        vars.each { |k, v| instance_variable_set("@#{k}", v) }
      end
    end

  end
end
