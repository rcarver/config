class Config::Meta::Project < Config::Pattern

  desc "Path to project root"
  key :root

  desc "The domain that nodes use to create their FQDN"
  attr :project_hostname_domain

  desc "The URL for the project git repo"
  attr :project_git_config_url

  desc "The URL for the database git repo"
  attr :database_git_config_url

  def call
    file "#{root}/.gitignore" do |f|
      f.template = "gitignore.erb"
    end
    %w(.data blueprints patterns facts clusters).each do |d|
      dir "#{root}/#{d}"
    end
    file "#{root}/config.rb" do |f|
      f.template = "config.rb.erb"
    end
    file "#{root}/README.md" do |f|
      f.only_create!
      f.template = "project_readme.md.erb"
    end
  end

  # NOTE: this is an idea. let it sit.
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
