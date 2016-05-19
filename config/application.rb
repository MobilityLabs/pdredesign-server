require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PdrServer
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/workers #{config.root}/app/services)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.assets.initialize_on_precompile = false

    config.assets.enabled = true
    config.assets.paths << Rails.root.join('app', 'assets', 'resources', 'pdf')

    config.active_record.raise_in_transactional_callbacks = true
    config.angular_templates.module_name    = 'templates'
    config.angular_templates.inside_paths   = [Rails.root.join('app', 'assets', 'javascripts', 'client', 'views'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'inventories'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'analyses'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'access'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'navigation'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'forms'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'common_list'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'common_create'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'assessments'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'permissions'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'proprietary'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'reminders'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'home'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'learning_questions'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'buttons'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'consensus'),
                                               Rails.root.join('app', 'assets', 'javascripts', 'client', 'about')]
    config.angular_templates.markups        = %w(erb)
    config.angular_templates.htmlcompressor = false
  end
end
