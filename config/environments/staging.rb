Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.action_mailer.default_url_options = { host: 'https://go.staging.wundercoach.net', locale: 'de' }
  config.action_mailer.delivery_method = :test

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_files = false

  # Compress JavaScripts and CSS.
  # We use our own JS-compressor, which is a thin wrapper around uglifier
  # It skips assets that are marked with 'no_asset_compression'
  # Uglifier gets really slow if trying to compress files that already are compressed
  # It might even crash a deploy!
  # That's why we mark compressed assets with 'no_asset_compression' for faster, safer deploys
  config.assets.js_compressor = SelectiveAssetsCompressor.new
  # config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true
  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # config.middleware.use Rack::MailExceptions do |mail|
  #   mail.to 'stefan.luetge@siliconplanet.com'
  #   mail.from 'health-monitor@wundercoach.net'
  #   mail.smtp false
  # end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
