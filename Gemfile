source 'https://rubygems.org'
source 'https://rails-assets.org'
ruby '2.2.0'

gem 'rails', '~> 4.2.0'

gem 'puma'
gem 'pg'
gem 'sass-rails', '~> 4.0.2'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 1.2'
gem 'yajl-ruby'
gem 'devise', '3.4.1'
gem 'devise_masquerade'
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

gem 'premailer-rails'
gem 'zurb-ink-rails', '~> 1.0.5'

gem 'pdr_client', git: 'https://cf91ac52033be9b3a1d81b413955d22ab80c45e8:x-oauth-basic@github.com/MobilityLabs/pdr-client.git'
# gem 'pdr_client', path: '../pdr-client'
gem 'rails-assets-angular', :source => 'https://rails-assets.org/'

gem 'actionpack-action_caching'

group :development, :test do
  gem 'foreman'
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 3.1'
  gem 'rspec-collection_matchers'
  gem 'spring-commands-rspec'
  gem 'pry'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'annotate'
  gem 'letter_opener'
  gem 'letter_opener_web'
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem 'simplecov', '~> 0.7.1'
  gem 'shoulda-matchers', require: false
  gem 'faker'
  gem 'rspec-sidekiq'
end

group :production do
  gem 'memcachier'
  gem 'dalli'
  gem 'rails_12factor'
end
