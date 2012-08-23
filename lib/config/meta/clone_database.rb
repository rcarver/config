class Config::Meta::CloneDatabase < Config::Pattern

  desc "URL to clone from"
  key :url

  desc "Path to clone to"
  key :path

  def call
    script "clone the repo" do |s|
      s.code = <<-STR.dent
        if [ ! -d #{path} ]; then
          git clone #{url} #{path}
        fi
      STR
    end
  end
end

