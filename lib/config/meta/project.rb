class Config::Meta::Project < Config::Pattern

  desc "Path to project root"
  key :root

  def call
    dirp root
    %(blueprints patterns facts clusters).each do |d|
      dirp "#{root}/#{d}"
    end
    file "#{root}/README.md" do |f|
      f.template = "project_readme.md.erb"
    end
  end

  def if_changed
    [
      "init",
      "add .",
      "commit -m 'Initialize project'"
    ].each do |cmd|
      add Config::Patterns::Git do |git|
        git.dir = root
        git.cmd = cmd
      end
    end
  end
end
