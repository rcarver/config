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

      desc "Append content to the file instead of creating or replacing"
      attr :append, false

      def describe
        "File #{pn}"
      end

      # Public: Appending is a questionable operation so call it with
      # bang for confidence.
      #
      # Returns nothing.
      def append!
        self.append = true
      end

      def create

        if content
          new_content = content
        else
          unless template_path && template_context
            raise ArgumentError, "You must set either content or template_path and template_context"
          end
          unless template_context.respond_to?(:get_binding)
            raise ArgumentError, "template_context must define #get_binding"
          end
          template = ERB.new(::File.read(template_path))
          new_content = template.result(template_context.get_binding)
        end

        change_status = nil

        if pn.exist?
          existing_content = pn.read
          change_status = case
          when append
            "appended"
          # TODO: checksum to compare?
          when new_content != existing_content
            "updated"
          end
        else
          change_status = "created"
        end

        case change_status
        when "created", "updated"
          pn.open("w") { |f| f.print new_content }
          changes << change_status
        when "appended"
          pn.open("a") { |f| f.print new_content }
          changes << change_status
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

