source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Sometimes slug size can be reduced by repo interactions:
# heroku repo:gc --app funabiki-online
# heroku repo:purge_cache --app funabiki-online
# heroku config:set BUNDLE_WITHOUT="development:test" --app funabiki-online

#using rbenv locally https://github.com/rbenv/rbenv#installing-ruby-versions
ruby '2.6.6'

# Set up local .env file, require immediately
gem 'dotenv-rails', groups: [:development, :test], :require => 'dotenv/rails-now'

gem 'sidekiq'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails' 
gem 'rails', '~> 6.0.3.1'

# Use postgresql as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.11'

# For Scaling with Redis and Sidekiq 
# https://stackoverflow.com/questions/13770713/rails-starting-sidekiq-on-heroku
# https://github.com/mperham/sidekiq/wiki/Active+Job
gem 'redis', '~> 4.0.1'
gem 'hiredis'

# Default JS compiler for Rails 6
gem "webpacker"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Async partial rendering
gem 'render_async'

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

  #Redis tests
  gem 'redis-namespace'
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

#Add Charts (https://chartkick.com/)
#gem "chartkick"
gem 'groupdate'

#Add Devise for Authorization and Authentication
gem 'devise', '>= 4.7.1'

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

## PDF reader and writer
gem 'prawn-rails'

## On the fly Hankaku / Zenkaku Conversion (http://gimite.net/gimite/rubymess/moji.html)
gem 'moji', github: 'gimite/moji'

## API/HTTP Requests
gem 'httparty'

## Charts
gem 'chartkick'

## Browsing automation
gem 'mechanize'

## Finding next and previous entries for models https://github.com/glebm/order_query
gem 'order_query'

## For uploading/streaming CSV/XLS data to/from the client
gem 'csv'
gem 'spreadsheet'

## Weather API
gem 'weatherb'
gem 'faraday_middleware'