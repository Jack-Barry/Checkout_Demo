require 'minitest/autorun'

Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/test/*_test.rb'].each {|file| require file }