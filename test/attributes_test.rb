require_relative 'test_helper'

class SyncAttrExample
  include SyncAttr::Attributes

  sync_attr_reader :test1 do
    'hello world'
  end
  sync_attr_reader :test2
  sync_attr_accessor :test3
  sync_attr_accessor :test4 do
    'hello world 4'
  end

  sync_attr_accessor :test5
end

# Ensure that class and instance attributes are distinct
class SyncAttrExample2
  include SyncAttr::Attributes

  sync_attr_reader :test1 do
    'hello world instance'
  end
  sync_cattr_reader :test1 do
    'hello world class'
  end
end

class InstanceAttributesTest < Minitest::Test
  context "with example" do

    should 'lazy initialize attribute' do
      assert_equal 'hello world', SyncAttrExample.new.test1
    end

    should 'return nil on attribute without initializer' do
      assert_nil SyncAttrExample.new.test2
    end

    should 'set and then return a value for a class attribute without an initializer' do
      assert example = SyncAttrExample.new
      assert_nil example.test3
      assert_equal 'test3', (example.test3 = 'test3')
      assert_equal 'test3', example.test3
    end

    should 'lazy initialize attribute and also have writer' do
      assert example = SyncAttrExample.new
      assert_equal 'hello world 4', example.test4
      assert_equal 'test4', (example.test4 = 'test4')
      assert_equal 'test4', example.test4
    end

    should 'support setting a Proc within a synch block' do
      assert example = SyncAttrExample.new
      assert_nil example.test5

      # Returns the Proc
      example.test5 = Proc.new {|val| (val||0) + 1}
      assert_equal 1, example.test5

      example.test5 = Proc.new {|val| (val||0) + 1}
      assert_equal 2, example.test5
    end
  end

  context "with example2" do

    should 'have distinct class and instance attributes when they have the same name' do
      assert s = SyncAttrExample2.new
      assert_equal 'hello world instance', s.test1
      assert_equal 'hello world class', s.class.test1
    end

    should 'ensure that different objects have their own synchs' do
      assert ex1 = SyncAttrExample.new
      assert ex2 = SyncAttrExample2.new
      assert ex1.instance_variable_get(:@sync_attr_sync).object_id != ex2.instance_variable_get(:@sync_attr_sync).object_id
    end

    should 'ensure that objects and classes have their own synchs' do
      assert ex1 = SyncAttrExample.new
      assert SyncAttrExample.instance_variable_get(:@sync_attr_sync).object_id != ex1.instance_variable_get(:@sync_attr_sync).object_id
    end
  end
end
