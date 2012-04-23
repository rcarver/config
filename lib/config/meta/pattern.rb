class Config::Meta::Pattern < Config::Pattern

  desc "Path to project root"
  key :root

  desc "Name of the pattern topic"
  key :topic

  desc "Name of the pattern"
  key :name

  def call
    dir  "#{root}/patterns/#{topic}"
    file "#{root}/patterns/#{topic}/#{name}.rb" do |f|
      f.template = "pattern.rb.erb"
    end
    file "#{root}/patterns/#{topic}/README.md" do |f|
      f.append!
      f.template = "pattern_readme.md.erb"
    end
  end
end
