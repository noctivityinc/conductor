ENV["RAILS_ENV"] = "test"
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'active_record'
require 'active_record/version'
require 'active_record/fixtures'
require 'action_controller'
require 'action_controller/test_process'
require 'action_view'
require 'active_support'
require 'test/unit'
require 'conductor'
require 'shoulda'

require File.dirname(__FILE__) + '/../init.rb'


config = YAML::load(IO.read(File.dirname(__FILE__) + '/db/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'postgresql'])
ActiveRecord::Migration.verbose = false
load(File.dirname(__FILE__) + "/db/schema.rb")

@@cache = ActiveSupport::Cache::MemoryStore.new

class Test::Unit::TestCase
  
end
