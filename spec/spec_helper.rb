# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'support/code_coverage'
require 'rspec/rails'
require 'shoulda/matchers'


Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true

  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!

  config.include Requests::JsonHelpers, type: :controller
  config.include Devise::TestHelpers,   type: :controller

  config.order = "random"
end

RSpec::Matchers.define :include_only_one_of do |expected|
  match do |array|
    elements = 0
	array.each{ |elm| elements += 1 if elm == expected }
	elements == 1
  end
end

Authority.configure do |config|
  config.logger = Logger.new('/dev/null')
end


