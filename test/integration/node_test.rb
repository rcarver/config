require 'helper'

describe "filesystem", Config::Node do

  let(:the_blueprint) {
    Config::Blueprint.from_string("webserver", <<-STR, __FILE__, __LINE__)
      file "\#{cluster.webserver.webroot}/index.html" do |f|
        f.content = "<h1>Hello from \#{node.facts.public_ip}</h1>"
      end
    STR
  }

  let(:the_cluster) {
    Config::Cluster.from_string("staging", <<-STR, __FILE__, __LINE__)
      configure :webserver,
        webroot: "#{tmpdir}"
    STR
  }

  let(:facts) {
    Config::Core::Variables.new("node facts", :public_ip => "50.1.2.3")
  }

  subject { Config::Node.new(the_cluster, the_blueprint) }

  before do
    subject.facts = facts
  end

  it "executes" do
    subject.execute
    (tmpdir + "index.html").must_be :exist?
    (tmpdir + "index.html").read.must_equal "<h1>Hello from 50.1.2.3</h1>"
  end
end
