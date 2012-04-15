class Config::Meta::PatternCategory < Config::Pattern

  desc "Path to project root"
  key :root

  desc "Name of the pattern category"
  key :name

  def call
    dir  "#{root}/patterns"
    dir  "#{root}/patterns/#{name}"
    file "#{root}/patterns/#{name}/README.md" do |f|
      f.only_create!
      f.template = "pattern_category_readme.md.erb"
    end
  end
end


