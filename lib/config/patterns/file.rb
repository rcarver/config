require 'erubis'

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
        ["File", pn].compact.join(" ")
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

      class ColorizingEruby < Erubis::Eruby
        include Config::Core::Loggable

        def add_expr_literal(src, code)
          src << '_buf << (' << colorize(code) << ');'
        end

      protected

        def colorize(code)
          if log.color?
            '"' + log.colorize("#{code.strip}:", :blue) + log.colorize("\#{#{code}}", :red) + '"'
          else
            %("[#{code.strip}:\#{#{code}}]")
          end
        end
      end

      def prepare
        if content
          @new_content = String(content)
          log_content = @new_content
        else
          template = ::File.read(template_path)
          log_template = ColorizingEruby.new(template)
          log_content = log_template.result(template_context.get_binding)
          new_template = Erubis::Eruby.new(template)
          @new_content = new_template.result(template_context.get_binding)
        end
        log.indent(2) do
          log << ">>>"
          log << log_content
          log << "<<<"
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
            if @new_content == pn.read
              "identical"
            else
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
            changes << change_status
          when "appended"
            pn.open("a") { |f| f.print @new_content }
            changes << change_status
          when "identical"
            log.indent do
              log << "identical"
            end
          end
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
        @pn ||= Pathname.new(path).cleanpath if path
      end

    end
  end
end

