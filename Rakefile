require 'rake/clean'
require 'rake/testtask'

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'sync_attr/version'

task :gem do
  system "gem build sync_attr.gemspec"
end

task :publish => :gem do
  system "git tag -a v#{SyncAttr::VERSION} -m 'Tagging #{SyncAttr::VERSION}'"
  system "git push --tags"
  system "gem push sync_attr-#{SyncAttr::VERSION}.gem"
  system "rm sync_attr-#{SyncAttr::VERSION}.gem"
end

desc "Run Test Suite"
task :test do
  Rake::TestTask.new(:functional) do |t|
    t.test_files = FileList['test/*_test.rb']
    t.verbose    = true
  end

  Rake::Task['functional'].invoke
end

task :default => :test
