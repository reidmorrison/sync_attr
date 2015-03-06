require_relative 'test_helper'

class SyncCAttrExample
  sync_cattr_reader :test1 do
    'hello world'
  end
  sync_cattr_reader :test2
  sync_cattr_accessor :test3
  sync_cattr_accessor :test4 do
    'hello world 4'
  end

  sync_cattr_accessor :test5
end

class SyncCAttrExample2
  sync_cattr_reader :test1 do
    'another world'
  end
end

class ClassAttributesTest < Minitest::Test
  context "with example" do

    should 'lazy initialize class attribute' do
      assert_equal 'hello world', SyncCAttrExample.test1
    end

    should 'return nil on class attribute without initializer' do
      assert_nil SyncCAttrExample.test2
    end

    should 'set and then return a value for a class attribute without an initializer' do
      assert_nil SyncCAttrExample.test3
      assert_equal 'test3', (SyncCAttrExample.test3 = 'test3')
      assert_equal 'test3', SyncCAttrExample.test3
    end

    should 'lazy initialize class attribute and also have writer' do
      assert_equal 'hello world 4', SyncCAttrExample.test4
      assert_equal 'test4', (SyncCAttrExample.test4 = 'test4')
      assert_equal 'test4', SyncCAttrExample.test4
    end

    should 'support setting a Proc within a synch block' do
      assert_nil SyncCAttrExample.test5

      # Returns the Proc
      SyncCAttrExample.test5 = Proc.new {|val| (val||0) + 1}
      assert_equal 1, SyncCAttrExample.test5

      SyncCAttrExample.test5 = Proc.new {|val| (val||0) + 1}
      assert_equal 2, SyncCAttrExample.test5
    end
  end

  context "with example2" do

    should 'ensure that different classes have their own class attributes' do
      assert ex1 = SyncCAttrExample.new
      assert_equal 'hello world', ex1.class.test1
      assert ex2 = SyncCAttrExample2.new
      assert_equal 'another world', ex2.class.test1
      assert_equal 'hello world', ex1.class.test1

      assert !defined? ex2.class.test2
      assert !defined? ex2.class.test3
      assert !defined? ex2.class.test4
    end
  end
end
