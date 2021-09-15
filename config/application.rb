require File.expand_path('../boot', __FILE__)
ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Wundercoach
  # Die einfache Online-Seminarverwaltung.
  class Application < Rails::Application
    config.exceptions_app = self.routes
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/lib/compressor)
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**}')]

    config.generators do |g|
      g.test_framework nil
      g.assets false
      g.helper false
      g.stylesheets false
      g.jbuilder false
    end

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.

    # Datetimepickers work with UTC, so that's what we'll use
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :de
    config.i18n.fallbacks = true
    # config.assets.compile = true
    config.active_job.queue_adapter = :delayed_job

    config.assets.enabled = true
    config.assets.paths << Rails.root.join("private")
    config.assets.paths << Rails.root.join("private", "system")
    config.assets.paths << Rails.root.join("public", "system")

    # prevent deprecation warnings
    config.active_record.raise_in_transactional_callbacks = true

    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'ALLOWALL'
    }
  end
end
