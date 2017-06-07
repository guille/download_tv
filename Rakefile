require "bundler/gem_tasks"
require "rake/testtask"

task :default => :test

Rake::TestTask.new do |t|
	t.libs << "lib"
	t.libs << "test"
	t.test_files = FileList["test/**/*_test.rb"]
	t.verbose = false
end

task :clean do
  rm_rf "config.rb"
  rm_rf "cookie"
  rm_rf "date"
end
