load "Rakefile.base"

require 'rake/testtask'

desc "Run the tests"
task :test => [:test_fast, :test_slow]

desc "Run all of the tests"
task :test_all => [:test_fast, :test_slow, :test_acceptance]

desc "Run the fast tests"
Rake::TestTask.new(:test_fast) do |t|
  t.libs.push "lib", "test"
  t.test_files = FileList['test/{config,integration}/**/*_test.rb']
  t.verbose = true
end

desc "Run the slow tests"
Rake::TestTask.new(:test_slow) do |t|
  t.libs.push "lib", "test"
  t.test_files = FileList['test/slow/**/*_test.rb']
  t.verbose = true
end

desc "Run the acceptance tests"
task :test_acceptance do
  sh "test/acceptance/test.sh"
end

# desc "Run the server"
# task :run do
# end
#

desc "Update the binaries"
task :binaries do
  require 'config/cli'
  rm_rf "bin"
  mkdir "bin"
  Config::CLI.binaries.keys.each do |name|
    File.open("bin/#{name}", "w") do |f|
      f.print <<-STR
#!/usr/bin/env ruby
require 'config/cli/exec'
      STR
    end
    chmod 0755, "bin/#{name}"
  end
end

desc 'Build the manual'
task :man do
  require 'ronn'
  require 'config/version'
  ENV['RONN_MANUAL']  = "Config Manual"
  ENV['RONN_ORGANIZATION'] = "Config #{Config::VERSION}"
  sh "ronn --warnings --style toc --html man/*.ronn"
end

# https://github.com/rtomayko/ronn/blob/master/Rakefile
desc 'Publish to github pages'
task :pages => :man do
  puts '----------------------------------------------'
  puts 'Rebuilding pages ...'
  verbose(true) {
    rm_rf 'pages'
    push_url = `git remote show origin`.split("\n").grep(/Push.*URL/).first[/git@.*/]
    sh <<-STR, :verbose => true
      set -e
      git fetch -q origin
      rev=$(git rev-parse origin/gh-pages)
      git clone -q -b gh-pages . pages
      cd pages
      git reset --hard $rev
      mkdir -p man
      rm -f man/*.html
      cp -rp ../man/*.html ./man
      git add man/*.html
      git commit -m 'rebuild manual'
      git push #{push_url} gh-pages
    STR
  }
end

