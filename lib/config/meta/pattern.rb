class Config::Meta::Pattern < Config::Pattern

  desc "Path to project root"
  key :root

  desc "Name of the pattern category"
  key :category

  desc "Name of the pattern"
  key :name

  def call
    dirp "#{root}/patterns/#{category}"
    file "#{root}/patterns/#{category}/#{name}.rb" do |f|
      f.template = "pattern.rb.erb"
    end
    file "#{root}/patterns/#{category}/README.md" do |f|
      f.append!
      f.template = "pattern_readme.md.erb"
    end
  end
end
