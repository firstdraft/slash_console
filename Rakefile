require "bundler/setup"

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"].exclude("test/system/**/*", "test/dummy/**/*")
  t.verbose = false
end

Rake::TestTask.new("test:system") do |t|
  t.libs << "test"
  t.test_files = FileList["test/system/**/*_test.rb"]
  t.verbose = false
end

task default: :test
