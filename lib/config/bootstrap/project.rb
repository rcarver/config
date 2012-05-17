module Config
  module Bootstrap
    # Generates a script to bootstrap the project. To bootstrap the
    # project we clone your git repo and set it to a specified git ref.
    class Project < ::Config::Pattern

      desc "Path to write the configuration to"
      attr :path

      desc "URI of the project's git repo"
      key  :git_uri

      def call
        file path do |f|
          f.template = "project.erb"
        end
      end

    end
  end
end
