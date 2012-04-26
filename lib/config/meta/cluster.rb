class Config::Meta::Cluster < Config::Pattern

  desc "Path to project root"
  key :root

  desc "Name of the cluster"
  key :name

  def call
    dir  "#{root}/clusters"
    file "#{root}/clusters/#{name}.rb" do |f|
      f.template = "cluster.rb.erb"
    end
  end
end



