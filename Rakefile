load "Rakefile.base"

require 'rake/testtask'

desc "Run the tests"
task :test => [:test_fast, :test_slow]

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

# desc "Run the server"
# task :run do
# end
#

desc 'Build the manual'
task :man do
  require 'ronn'
  require 'config/version'
  ENV['RONN_MANUAL']  = "Config Manual"
  ENV['RONN_ORGANIZATION'] = "Config #{Config::VERSION}"
  sh "ronn --warnings --style toc --html man/*.ronn"
end

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
      rm -f man/ronn*.html
      cp -rp ../man/ronn*.html ./man
      git add man
      git commit -m 'rebuild manual'
      git push #{push_url} gh-pages
    STR
  }
end

