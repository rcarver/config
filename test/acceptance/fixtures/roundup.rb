bash "install roundup" do |s|
  s.env = { "ROUNDUP_VERSION" => "v0.0.5" }
  s.code = <<-STR.dent
    cd /usr/src
    curl -sL https://github.com/bmizerany/roundup/tarball/$ROUNDUP_VERSION | tar xvzf -
    cd bmizerany-roundup-*
    ./configure
    make && make install
  STR
  s.not_if = "test -d /usr/src/roundup"
end

file "/home/vagrant/run-tests" do |f|
  f.content = <<-STR.dent
    #!/bin/bash
    cd /tmp/config/test/acceptance/tests
    color=always sudo /usr/local/bin/roundup
  STR
  f.mode = 0755
end
