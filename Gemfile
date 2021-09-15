source 'https://rubygems.org'

ruby '2.3.1'

gem 'cells-rails'
gem 'cells-slim'
gem 'dry-types'
gem 'rack-contrib' # used for informing us about any exception in production
gem 'rails', '~> 4.2.7.1'
gem 'trailblazer-cells'
gem 'trailblazer-rails', '~> 1.0.4'

# Style and Icons
gem 'bootstrap-sass'
gem 'compass-rails' # do we use this?
gem 'font-awesome-rails'
gem 'sass-rails' # Use SCSS for stylesheets

# Custom Inputs
gem 'bootstrap-datepicker-rails'
gem 'bootstrap-timepicker-rails'
gem 'bootstrap-wysihtml5-rails', git: 'https://github.com/thinkei/bootstrap-wysihtml5-rails', branch: 'cannot-edit-link'
gem 'bootstrap-x-editable-rails'
gem 'best_in_place'
gem 'chosen-rails' # sexy select
gem 'country_select'
gem 'datetimepicker-rails', git: 'https://github.com/zpaulovics/datetimepicker-rails', branch: 'master', submodules: true
gem 'icheck-rails' # fancy checkboxes / radiobuttons
gem 'jquery-minicolors-rails'
gem 'switchery-rails' # iOS Style checkboxes
gem 'trix'
gem 'fullcalendar-rails'

# Views, Decorators, Widgets and View Utility
gem 'draper', '~> 1.3' # decorators for models
gem 'gmaps4rails' # Google Maps
gem 'jbuilder' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'liquid', '~> 4.0'
gem 'nokogiri'
gem 'simple_form'
gem 'simple_form-magic_submit'
gem 'slim-rails'
gem 'will_paginate', '~> 3.0'
gem 'will_paginate-bootstrap'

# Javascript
gem 'coffee-rails', '~> 4.0.0' # Use CoffeeScript for .js.coffee assets and views
gem 'coffee-script-source', '~> 1.11.1'
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'jquery-ui-rails'
gem 'momentjs-rails', '>= 2.9.0'
gem 'therubyracer', platforms: :ruby # See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'highcharts-rails'
gem 'rails-assets-bootstrap-chosen', source: 'https://rails-assets.org'
gem 'rails-assets-listjs', source: 'https://rails-assets.org'
gem 'turbolinks'

# Third Party and APIs
gem 'active_campaign'
gem 'axlsx_rails'
gem 'geocoder'
gem 'geokit-rails'
gem 'gibbon' # mailchimp adapter
gem 'gocardless_pro'
gem 'httpi'
gem 'stripe', '3.6.0'
#, git: 'https://github.com/stripe/stripe-ruby'
gem 'stripe_event', '1.8.0' # for webhooks
gem 'rubyzip' # will load new rubyzip version
gem 'zip-zip'
gem 'graphql'
gem 'graphiql-rails'

# ActiveRecord, Database and Storage
gem 'acts_as_list'
gem 'deep_cloneable', '~> 2.1.1'
gem 'mysql2'
gem 'nilify_blanks' # nil values before save if empty
gem 'paperclip', '4.3.6'
gem 'paranoia', '~> 2.0' # soft delete
gem 'ransack'

# I18n, L10n etc.
gem 'browser-timezone-rails'
gem 'globalize', '~> 5.0.0'
gem 'i18n-timezones'
gem 'money-rails', '~>1'
gem 'rails-assets-jsTimezoneDetect'

# PDF
gem 'wicked_pdf' # wkhtmltopdf wrapper
gem 'wkhtmltopdf-binary'

# Authentication and Authorization
gem 'acts_as_tenant' # Multi Tenancy
gem 'cancancan' # Authorization
gem 'oauth2' # OAuth used by Gocardless
gem 'sorcery' # Authentication
gem 'invisible_captcha'

# Background processing
gem 'daemons'
gem 'delayed_job_active_record'

# Admin Views, metrics, charts
gem 'chartkick' # battle-proven charts, by Instacart
gem 'groupdate' # group by date. Timezone-aware
gem 'rails_admin'

# Misc
gem 'countries' # work with countries
gem 'figaro' # for environment variables
gem 'friendly_id', '~> 5.1.0' # sexy urls
gem 'non-stupid-digest-assets'
gem 'pry'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# group :staging do
#   gem 'faker'
#   gem 'populator'
#   gem 'byebug'
#   gem 'capistrano', '3.4.0', require: false
#   gem 'capistrano-rbenv', github: 'capistrano/rbenv', require: false
#   gem 'capistrano-bundler', '~> 1.1', require: false
#   gem 'capistrano-db-tasks', require: false # sync db and assets with remote app
#   gem 'capistrano-faster-assets', '~> 1.0'
#   gem 'capistrano-passenger', require: false
#   gem 'capistrano-rails', '~> 1.1', require: false
#   gem 'capistrano3-delayed-job', '~> 1.0', require: false
# end
#
group :test do
  gem 'capybara' # run tests in a headless browser
  gem 'factory_girl_rails' # for populating the test database
  gem 'fuubar' # formatting for rspec
  gem 'rspec-mocks' # mocks and stubs for rspec
  gem 'rspec-rails' # most popular ruby test framework
  gem 'simplecov', require: false # log code coverage
  gem 'sqlite3' # use sqlite3 for the test database
  gem 'faker'
  gem 'stripe-ruby-mock', '~> 2.5.8', :require => 'stripe_mock'
  gem 'webmock'
end

group :development, :test do
  gem 'byebug' # halt execution for debugging
end

group :development, :staging do
  gem 'bigdecimal', '1.3.5'
  gem 'axlsx', '~> 2.0', require: false
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman', require: false # No. 1 Static Vulnerability Scanner for Rails
  gem 'bullet' # find inefficient N+1 queries
  gem 'capistrano', '3.4.0', require: false
  gem 'capistrano-rbenv', github: 'capistrano/rbenv', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-db-tasks', require: false # sync db and assets with remote app
  gem 'capistrano-faster-assets', '~> 1.0'
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano3-delayed-job', '~> 1.0', require: false
  gem 'faker'
  gem 'i18n-tasks', '~> 0.9.5', require: false # find missing translations
  # gem 'letter_opener' # show Mails in Browser instead of sending them
  gem 'letter_opener_web'
  gem 'populator'
  gem 'quiet_assets' # don't show assets in log
  gem 'seed_dump'
  gem 'spring' # speed up command line tasks (rake and rails)
  gem 'spring-commands-rspec'
  gem 'traceroute' # find unused routes
end

gem 'graphiql-rails', group: :development
gem 'puma', '3.7.1', group: :production