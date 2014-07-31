source 'https://rubygems.org'
source 'https://rails-assets.org'
ruby '2.1.2'

gem 'rails', '~> 4.1.0'

gem 'unicorn'
gem 'pg'
gem 'sass-rails', '~> 4.0.2'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 1.2'
gem 'yajl-ruby'
gem 'devise', '~> 3.2'
gem 'bcrypt', '~> 3.1.7'
gem 'activerecord-session_store'
gem 'sidekiq'
gem 'rails_admin'
gem 'authority'

gem 'fog'
gem 'mini_magick'
gem 'carrierwave'
gem 'twitter'
gem 'mandrill-api'
gem 'mandrill_mailer'

gem 'descriptive-statistics'

# gem 'pdr_client', git: 'https://cf91ac52033be9b3a1d81b413955d22ab80c45e8:x-oauth-basic@github.com/MobilityLabs/pdr-client.git'
gem 'pdr_client', path: '../pdr-client'

group :development, :test do
  gem 'foreman'
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 3.0.1'
  gem 'rspec-collection_matchers'
  gem 'spring-commands-rspec'
  gem 'pry'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'annotate'
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem 'simplecov', '~> 0.7.1'
  gem 'shoulda-matchers', require: false
  gem 'faker'
  gem 'rspec-sidekiq'
end

group :production do
  gem 'rails_12factor'
end
