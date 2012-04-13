class Config::Meta::Blueprint < Config::Pattern

  desc "Path to project root"
  key :root

  desc "Name of the blueprint"
  key :name

  def call
    dirp "#{root}/blueprints"
    file "#{root}/blueprints/#{name}.rb" do |f|
      f.template = "blueprint.rb.erb"
    end
  end
end


