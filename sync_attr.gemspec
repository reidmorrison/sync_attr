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
  s.summary     = "Create thread-safe class and instance attributes"
  s.description = "When working in a multi-threaded environment it is important to ensure that any attributes that are shared across threads are properly protected to ensure that inconsistent data is not created. Lazy initializing these safe attributes improves startup times and only creates resources when they are needed."
  s.files       = Dir["lib/**/*", "LICENSE.txt", "Rakefile", "README.md"]
  s.test_files  = Dir["test/**/*"]
  s.license     = "Apache License V2.0"
  s.has_rdoc    = true
end
