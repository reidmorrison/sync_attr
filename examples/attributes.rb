# Class Attribute Example
#
require 'sync_attr'

# Sample class with lazy initialized Synchronized Class Attributes
class Person
  include SyncAttr::Attributes

  # Thread safe Instance Attribute reader for name
  # Sets :name only when it is first called
  # Ideal for when name is loaded after startup from a database or config file
  sync_attr_reader :name do
    "Joe Bloggs"
  end

  # Thread safe Instance Attribute reader and writer for age
  # Sets :age only when it is first called
  sync_attr_accessor :age do
    21
  end
end

person = Person.new
puts "The person is #{person.name} with age #{person.age}"

person.age = 22
puts "The person is #{person.name} now has age #{person.age}"

person.age = Proc.new {|age| age += 1 }
puts "The person is #{person.name} now has age #{person.age}"

# Changes to person above do not affect any changes to second_person
# Also, the initial value that is lazy loaded into name is unaffected by person above
second_person = Person.new
puts "The second person is #{second_person.name} with age #{second_person.age}"
