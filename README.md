sync_attr [![Build Status](https://secure.travis-ci.org/reidmorrison/sync_attr.png?branch=master)](http://travis-ci.org/reidmorrison/sync_attr)
=========

Create thread-safe class and instance attributes

* http://github.com/reidmorrison/sync_attr

## Introduction

When working in a multi-threaded environment it is important to ensure that
any attributes that are shared across threads are properly protected to ensure
that inconsistent data is not created. Lazy initializing these safe attributes
improves startup times and only creates resources when they are needed.

For example, without sync_attr if two threads attempt to write to the
same attribute at the same time it is not deterministic what the results will be.
This condition is made worse when two threads attempt to initialize class instance
attributes at the same time that could take a second or longer to complete.

A `sync_cattr_reader` is ideal for holding data loaded from configuration files.
Also, shared objects, such as connection pools can be safely initialized and
shared in this way across hundreds of threads.
Once initialized all reads are shared without locks since no writer is defined.

Aside from safely sharing reads `sync_cattr_accessor` also ensures that data
is not read while it is being modified. The writes are completely thread-safe
ensuring that only one thread is modifying the value at a time and that reads
are suspended until the write is complete.

## Features

* Adds thread-safe accessors for class instance attributes.
* Supports shared read access to class and instance attributes. This allows
  multiple threads to read the attribute, but will block all reads and writes whilst
  the attribute is being modified.
* Prevents attributes from being read while it is being updated or initialized for
  the first time.
* Thread-safe attribute lazy initialization.
  Lazy initialization allows class attributes to be loaded only when first read.
  As a result it's value can be read for the first time from a database or
  configuration file once and only when needed.
* Avoids having to create yet another Rails initializer.
* Avoids costly startup initialization when the initialized data may never be accessed
  For example when Rake tasks are run, they may not need access to everything in
  the Rails environment.
* Works in regular Ruby and does not require Rails, or any other gems.

## Thread-safe Class Attribute example

Create a reader for a class attribute and lazy initialize its value on the first
attempt to read it. I.e. Lazy initialize the value.

Very useful for initializing shared services that take time to initialize.
In particular services that may not even be called in a specific process,
for example when running rake, or when opening a console.

An optional block can be supplied to initialize the synchronized class attribute
when it is first read. The initializer is thread safe and will block all other
reads to this attribute while it is being initialized. This ensures that the
initializer is only run once and that all threads to call the reader receive the
same value, regardless of how many threads call the reader at the same time.

Example:

```ruby
require 'sync_attr'

# Sample class with lazy initialized Thread-safe Class Attributes
class Person
  # Create a reader for the class attribute :name
  # and lazy initialize the value to 'Joe Bloggs' only on the first
  # call to the reader.
  # Ideal for when :name is loaded from a database or configuration file.
  sync_cattr_reader :name do
    'Joe Bloggs'
  end

  # Create a reader and a writer for the class attribute :age
  # and lazy initialize the value to 21 only on the first
  # call to the reader.
  sync_cattr_accessor :age do
    21
  end
end

puts "The person is #{Person.name} with age #{Person.age}"

Person.age = 22
puts "The person is #{Person.name} now has age #{Person.age}"

# => The person is Joe Bloggs now has age 22

Person.age = Proc.new {|age| age += 1 }
puts "The person is #{Person.name} now has age #{Person.age}"

# => The person is Joe Bloggs now has age 23
```

## Synchronized Instance Attribute example

Example:

```ruby
require 'sync_attr'

# Sample class with lazy initialized Thread-safe attributes
class Person
  include SyncAttr::Attributes

  # Create a reader for the thread-safe attribute :name
  # and lazy initialize the value to 'Joe Bloggs' only on the first
  # call to the reader.
  sync_attr_reader :name do
    'Joe Bloggs'
  end

  # Create a thread-safe reader and a writer for the attribute :age
  # and lazy initialize the value to 21 only on the first
  # call to the reader.
  sync_attr_accessor :age do
    21
  end
end

person = Person.new
puts "The person is #{person.name} with age #{person.age}"

# => The person is Joe Bloggs with age 21

person.age = 22
puts "The person is #{person.name} now has age #{person.age}"

# => The person is Joe Bloggs now has age 22

person.age = Proc.new {|age| age += 1 }
puts "The person is #{person.name} now has age #{person.age}"

# => The person is Joe Bloggs now has age 23
```

## Install

  gem install sync_attr

Meta
----

* Code: `git clone git://github.com/reidmorrison/sync_attr.git`
* Home: <https://github.com/reidmorrison/sync_attr>
* Bugs: <http://github.com/reidmorrison/sync_attr/issues>
* Gems: <http://rubygems.org/gems/sync_attr>

This project uses [Semantic Versioning](http://semver.org/).

Authors
-------

Reid Morrison :: reidmo@gmail.com :: @reidmorrison

License
-------

Copyright 2012, 2013, 2014, 2015 Reid Morrison

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
