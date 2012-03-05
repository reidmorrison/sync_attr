# Class Attribute Example
#
require 'sync_attr'

# Sample class with lazy initialized Synchronized Class Attributes
class Person
  include SyncAttr

  # Thread safe Class Attribute reader for name
  # Sets :name only when it is first called
  # Ideal for when name is loaded after startup from a database or config file
  sync_cattr_reader :name do
    "Joe Bloggs"
  end

  # Thread safe Class Attribute reader and writer for age
  # Sets :age only when it is first called
  sync_cattr_accessor :age do
    21
  end
end

puts "The person is #{Person.name} with age #{Person.age}"

Person.age = 22
puts "The person is #{Person.name} now has age #{Person.age}"

Person.age = Proc.new {|age| age += 1 }
puts "The person is #{Person.name} now has age #{Person.age}"

