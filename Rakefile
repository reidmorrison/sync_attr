lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rubygems'
require 'rubygems/package'
require 'rake/clean'
require 'rake/testtask'
require 'date'
require 'sync_attr/version'

desc "Build gem"
task :gem  do |t|
  gemspec = Gem::Specification.new do |s|
    s.name        = 'sync_attr'
    s.version     = SyncAttr::VERSION
    s.platform    = Gem::Platform::RUBY
    s.authors     = ['Reid Morrison']
    s.email       = ['reidmo@gmail.com']
    s.homepage    = 'https://github.com/reidmorrison/sync_attr'
    s.date        = Date.today.to_s
    s.summary     = "Thread safe accessors for Ruby class and instance attributes. Supports thread safe lazy loading of attributes"
    s.description = "SyncAttr is a mixin to read, write and lazy initialize both class and instance variables in a multi-threaded environment when the attribute could be modified by two threads at the same time, written in Ruby."
    s.files       = FileList["./**/*"].exclude(/\.gem$/, /\.log$/,/nbproject/).map{|f| f.sub(/^\.\//, '')}
    s.license     = "Apache License V2.0"
    s.has_rdoc    = true
  end
  Gem::Package.build gemspec
end

desc "Run Test Suite"
task :test do
  Rake::TestTask.new(:unit) do |t|
    t.test_files = FileList['test/*_test.rb']
    t.verbose    = true
  end

  Rake::Task['unit'].invoke
end
