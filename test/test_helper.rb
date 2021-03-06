$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'yaml'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/stub_any_instance'
require 'shoulda/context'
require 'sync_attr'
require 'awesome_print'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
