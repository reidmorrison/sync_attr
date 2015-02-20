lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

# Maintain your gem's version:
require 'sync_attr/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'sync_attr'
  s.version     = SyncAttr::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Reid Morrison']
  s.email       = ['reidmo@gmail.com']
  s.homepage    = 'https://github.com/reidmorrison/sync_attr'
  s.summary     = "Thread safe accessors for Ruby class and instance attributes. Supports thread safe lazy loading of attributes"
  s.description = "SyncAttr is a mixin to read, write and lazy initialize both class and instance variables in a multi-threaded environment when the attribute could be modified by two threads at the same time, written in Ruby."
  s.files       = Dir["lib/**/*", "LICENSE.txt", "Rakefile", "README.md"]
  s.test_files  = Dir["test/**/*"]
  s.license     = "Apache License V2.0"
  s.has_rdoc    = true
end
