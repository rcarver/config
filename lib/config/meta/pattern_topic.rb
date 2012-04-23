class Config::Meta::PatternTopic < Config::Pattern

  desc "Path to project root"
  key :root

  desc "Name of the pattern topic"
  key :name

  def call
    dir  "#{root}/patterns"
    dir  "#{root}/patterns/#{name}"
    file "#{root}/patterns/#{name}/README.md" do |f|
      f.only_create!
      f.template = "pattern_topic_readme.md.erb"
    end
  end
end


