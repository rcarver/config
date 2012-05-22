module Config
  module Patterns
    class Package < Config::Pattern

      desc "Name of the package"
      key :name

      desc "Version of the package"
      attr :version, nil

      def describe
        if version
          "Package #{name.inspect} at #{version.inspect}"
        else
          "Package #{name.inspect}"
        end
      end

      def call
        if version
          add Config::Patterns::Script do |s|
            s.name = "install #{name} at #{version}"
            s.code = "apt-get install #{name} --version=#{version}" 
            s.reverse = "apt-get remove #{name}"
          end
        else
          add Config::Patterns::Script do |s|
            s.name = "install #{name}"
            s.code = "apt-get install #{name}" 
            s.reverse = "apt-get remove #{name}"
          end
        end
      end

    end
  end
end


