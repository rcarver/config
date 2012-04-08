load "Rakefile.base"

require 'rake/testtask'

desc "Run the tests"
Rake::TestTask.new do |t|
  t.libs.push "lib", "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

# desc "Run the server"
# task :run do
# end
