source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Sometimes slug size can be reduced by repo interactions:
# heroku repo:gc --app funabiki-online
# heroku repo:purge_cache --app funabiki-online
# heroku config:set BUNDLE_WITHOUT="development:test" --app funabiki-online

#using rbenv locally https://github.com/rbenv/rbenv#installing-ruby-versions
ruby '2.6.5'

# Set up local .env file, require immediately
gem 'dotenv-rails', :require => 'dotenv/rails-now'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails' 
gem 'rails', '~> 5.2.1'

# Use postgresql as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.11'

gem 'redis', '~> 4.0.1'
gem 'hiredis'
# For Scaling with Redis and Sidekiq (see: https://stackoverflow.com/questions/13770713/rails-starting-sidekiq-on-heroku)
# Keeping redis for now. https://blog.heroku.com/rails-database-optimization
# Costs 7 more bucks for each worker so not adding this for the time being.
# If we want to start with Sidekiq, add this to procfile "worker: bundle exec sidekiq -c 1 -q default -q tasks"
# Uncomment the lines in the files "config/sidekiq.yml" and "config/initalizers/redis.rb"
# Enable RedisToGo, change the Env variable and turn on the Worker from the dashboard or from CLI.
#gem 'sidekiq', '~> 2.7', '>= 2.7.1'

# Default JS compiler for Rail 6
gem "webpacker"

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
#gem 'duktape'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

#For debugging/analyzing Hash/API output, etc.
gem 'awesome_print'

#Heroku's Metrics for Ruby
gem 'barnes'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'listen'
  gem 'rubocop', require: false
  #visualize associations
  gem 'rails-erd'

  ## Dump Seeds and reset pk squence for reproducing the production database
  #gem 'seed_dump'
  #gem 'activerecord-reset-pk-sequence'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Mailcatcher for local mail debugging
  gem 'mailcatcher'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'webdrivers'
end
  
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

#Add Sprockets for installing gems
gem 'sprockets-rails', '>= 2.3.2', :require => 'sprockets/railtie'

#Add Bootstrap datepicker
gem 'bootstrap', '>= 4.1.3'
gem 'bootstrap-datepicker-rails', :require => 'bootstrap-datepicker-rails',
                                  :git => 'https://github.com/Nerian/bootstrap-datepicker-rails.git'

#Add JQuery (for Bootstrap)
gem 'jquery-rails', '~> 4.3.1'

#Add Charts (https://chartkick.com/)
gem "chartkick"
gem 'groupdate'

#Add Devise for Authorization and Authentication
gem 'devise', '>= 4.7.1'

#Add Font Awesome Icons
gem 'font-awesome-sass', '~> 5.2.0'

#Mini-Magick for Image Processing (のし Generator)
gem 'mini_magick'

#Auto-upload setup for Google
gem 'carrierwave'
gem 'carrierwave-google-storage'

# Easy Categories for Manual Articles
gem 'ancestry'

# Simple Form
gem 'simple_form'

# Sendgrid for confirmations, etc.
gem 'sendgrid-ruby'

## Gemfile for Rails 3+, Sinatra, and Merb
gem 'will_paginate', '~> 3.1.1'

## PDF reader and writer for Rakuten Manifests
gem 'prawn'
gem 'prawn-table'

## On the fly Hankaku / Zenkaku Conversion (http://gimite.net/gimite/rubymess/moji.html)
gem 'moji', github: 'gimite/moji'

## API/HTTP Requests
gem 'httparty'
gem 'woocommerce_api'

## Browsing automation
gem 'mechanize'

## Calendar https://medium.com/@a01700666/fullcalendar-in-ruby-on-rails-f98816950039
gem 'fullcalendar-rails'
gem 'momentjs-rails'

## Finding next and previous entries for models https://github.com/glebm/order_query
gem 'order_query', '~> 0.5.0'

## Trying to fix a known embedded font issue for ttfunk in Prawn 
## see: https://stackoverflow.com/questions/59743505/embedded-font-error-for-rails-prawn-document
gem 'ttfunk', '~> 1.6.2'

## For uploading data
gem 'csv'