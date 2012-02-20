sync_attr
=========

* http://github.com/ClarityServices/sync_attr

### Introduction

When working in a multithreaded environment it is important to ensure that
any attributes that are shared across threads are properly protected to ensure
that inconsistent data is not created.

For example, without sync_attr if two threads attempt to write to the
same attribute at the same time it is not deterministic what the results will be.
This condition is made worse when two threads attempt to initialize class variables
at the same time that could take a second or longer to complete. 

### Features

* Adds thread-safe accessors for class attributes
* Allows shared read access to class and instance attributes. This allows
  multiple threads to read the attribute, but will block all reads and writes whilst
  the attribute is being modified.
* Prevents attributes from being read while it is being updated or initialized for
  the first time.
* Thread-safe attribute lazy initialization
  Lazy initialization allows class attributes to be loaded only when first read.
  As a result it's value can be read for the first time from a database or config file
  once and only when needed.
* Avoids having to create yet another Rails initializer
* Avoids costly startup initialization when the initialized data may never be accessed
  For example when Rake tasks are run, they may not need access to everything in
  the Rails environment
* Not dependent on Rails

### Examples

    require 'sync_attr'

    # Sample class with lazy initialized Synchronized Class Attributes
    def Person
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

    person = Person.new
    puts "The person is #{person.name} with age #{person.age}"

    person.age = 22
    puts "The person is #{person.name} now has age #{person.age}"

    person.age = Proc.new {|age| age += 1 }
    puts "The person is #{person.name} now has age #{person.age}"

### Install

  gem install sync_attr

Meta
----

* Code: `git clone git://github.com/ClarityServices/sync_attr.git`
* Home: <https://github.com/ClarityServices/sync_attr>
* Docs: <http://ClarityServices.github.com/sync_attr/>
* Bugs: <http://github.com/reidmorrison/sync_attr/issues>
* Gems: <http://rubygems.org/gems/sync_attr>

This project uses [Semantic Versioning](http://semver.org/).

Authors
-------

Reid Morrison :: reidmo@gmail.com :: @reidmorrison

License
-------

Copyright 2012 Clarity Services, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
