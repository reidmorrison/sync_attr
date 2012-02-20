# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'sync_attr'

class SynchAttrExample
  include SyncAttr

  sync_cattr_reader :test do
    'hello world'
  end
  sync_cattr_reader :test2
  sync_cattr_accessor :test3
  sync_cattr_accessor :test4 do
    'hello world 4'
  end

  sync_cattr_accessor :test5
end

class SynchAttrExample2
  include SyncAttr

  sync_cattr_reader :test do
    'hello world'
  end
end

class ClassAttributesTest < Test::Unit::TestCase
  context "with example" do

    should 'lazy initialize class attribute' do
      assert_equal 'hello world', SynchAttrExample.test
    end

    should 'return nil on class attribute without initializer' do
      assert_nil SynchAttrExample.test2
    end

    should 'set and then return a value for a class attribute without an initializer' do
      assert_nil SynchAttrExample.test3
      assert_equal 'test3', (SynchAttrExample.test3 = 'test3')
      assert_equal 'test3', SynchAttrExample.test3
    end

    should 'lazy initialize class attribute and also have writer' do
      assert_equal 'hello world 4', SynchAttrExample.test4
      assert_equal 'test4', (SynchAttrExample.test4 = 'test4')
      assert_equal 'test4', SynchAttrExample.test4
    end

    should 'support setting a Proc within a synch block' do
      assert_nil SynchAttrExample.test5

      # Returns the Proc
      SynchAttrExample.test5 = Proc.new {|val| (val||0) + 1}
      assert_equal 1, SynchAttrExample.test5

      SynchAttrExample.test5 = Proc.new {|val| (val||0) + 1}
      assert_equal 2, SynchAttrExample.test5
    end
  end

  context "with example2" do

    should 'ensure that different classes have their own synch instances' do
      assert ex1 = SynchAttrExample.new
      assert ex2 = SynchAttrExample2.new
      assert ex1.class.send(:sync_attr_sync).object_id != ex2.class.send(:sync_attr_sync).object_id
    end
  end
end
