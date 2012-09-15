bash "install roundup" do |s|
  s.code = <<-STR.dent
    cd /usr/src
    git clone git://github.com/bmizerany/roundup.git
    cd roundup
    git checkout v0.0.5
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
