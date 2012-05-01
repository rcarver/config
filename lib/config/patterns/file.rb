require 'erb'

module Config
  module Patterns
    class File < Config::Pattern

      desc "The full path of the file"
      key :path

      desc "The user that owns the file"
      attr :owner, nil

      desc "The group that owns the file"
      attr :group, nil

      desc "The octal mode of the file, such as 0755"
      attr :mode, nil

      desc "Set the mtime of the file to now"
      attr :touch, false

      desc "Specify the literal file content"
      attr :content, nil

      desc "Specify that content comes from a template file"
      attr :template_path, nil

      desc "Specify the object to provide the template binding"
      attr :template_context, nil

      desc "The operation to perform. See append! and only_create!"
      attr :operation, :write

      def describe
        "File #{pn}"
      end

      # Public: Appending is a questionable operation so call it with
      # bang for confidence.
      #
      # Returns nothing.
      def append!
        self.operation = :append
      end

      # Public: Not modifying an existing file is a questionable
      # operation so call it with bang for confidence.
      #
      # Returns nothing.
      def only_create!
        self.operation = :only_create
      end

      def validate
        if content.nil?
          if template_path.nil? || template_context.nil?
            validation_errors << "You must set either `content` or (`template_path` and `template_context`)"
          end
          if template_path && !::File.exist?(template_path)
            validation_errors << "template_path #{template_path} does not exist"
          end
          if template_context && !template_context.respond_to?(:get_binding)
            validation_errors << "template_context must define #get_binding"
          end
        end
      end

      def prepare
        if content
          @new_content = content
        else
          template = ERB.new(::File.read(template_path))
          @new_content = template.result(template_context.get_binding)
        end
        log.indent(2) do
          log << @new_content
        end
      end

      def create
        change_status = nil

        if pn.exist?
          change_status = case operation
          when :append
            "appended"
          when :write
            # TODO: checksum to compare? use File.identical?
            if @new_content != pn.read
              "updated"
            end
          end
        else
          change_status = "created"
        end

        if change_status
          case change_status
          when "created", "updated"
            pn.open("w") { |f| f.print @new_content }
          when "appended"
            pn.open("a") { |f| f.print @new_content }
          end
          changes << change_status
        else
          log << "identical"
        end

        #stat = Config::Core::Stat.new(self, path)
        #stat.owner = owner if owner
        #stat.group = group if group
        #stat.mode = mode if mode
        #stat.touch if touch
      end

      def destroy
        if pn.exist?
          pn.delete
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

