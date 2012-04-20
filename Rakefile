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
