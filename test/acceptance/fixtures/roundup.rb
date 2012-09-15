bash "install roundup" do |s|
  s.code = <<-STR.dent
    cd /usr/src
    curl -sL https://github.com/bmizerany/roundup/tarball/v0.0.5 | tar xvzf -
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
    color=always sudo /usr/src/roundup/roundup
  STR
  f.mode = 0755
end
