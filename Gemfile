# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# ruby '2.6.3'

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.1.0'

# Use sqlite3 as the database for Active Record

gem 'faker'
gem 'graphql'
gem 'jbuilder'
# gem 'psych', '< 4'
gem 'bootsnap', require: false
gem 'importmap-rails'
gem 'pg'
gem 'puma'
gem 'redis'
gem 'sassc-rails'
gem 'sidekiq', '~> 7.3'
gem 'sidekiq-cron'
gem 'sprockets-rails' # Opção 1 (mais comum)
gem 'sqlite3', '~> 1.4'
gem 'stimulus-rails'
gem 'turbo-rails'

group :development do
  gem 'web-console'
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem 'graphiql-rails'
  gem 'rack-mini-profiler', require: false
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  # robocop
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'ruby-lsp-rspec', require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '>= 2.15'
  gem 'capybara'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
