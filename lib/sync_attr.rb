# Synchronize access and lazy initialize one or more variables in a class
#
# Load configuration files and thread connection pools on demand rather than
# at start time or via a Rails initializer
#
# Locking: Shared reads and exclusive writes
#   sync_attr ensures that all reads are shared, meaning that all
#   reads to attributes can occur at the same time. All writes are exclusive, so
#   all reads and other writes will be blocked whilst a write takes place.
#
# Example:
# class MyClass
#   include SyncAttr
#
#    # Create class variable @@http and initialize on the first access
#    # protecting access by concurrent threads using a Semaphore
#    sync_cattr_reader :http do
#      PersistentHTTP.new()
#    end
#
# Author: Reid Morrison <reidmo@gmail.com>
require 'sync'
require 'sync_attr/version'
require 'sync_attr/class_attributes'
#require 'sync_attr/instance_attributes'

module SyncAttr
  # Add class methods and initialize mixin
  def self.included(base)
    base.extend(SyncAttr::ClassAttributes::ClassMethods)
    base.send(:sync_attr_class_attr_init)
  end
end
