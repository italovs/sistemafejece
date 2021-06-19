# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'active_storage_validations'
gem 'blind_index'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'devise'
gem 'devise-i18n'
gem 'google-cloud-storage'
gem 'mimemagic', github: 'mimemagicrb/mimemagic', ref: '01f92d86d15d85cfd0f20dabd025dcbd36a8a60f'
gem 'image_processing'
gem 'jbuilder', '~> 2.7'
gem 'lockbox'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'
gem 'rails', '~> 6.0.3', '>= 6.0.3.4'
gem 'rails-i18n'
gem 'rails_real_favicon'
gem 'ransack'
gem 'sass-rails', '>= 6'
gem 'selectize-rails'
gem 'turbolinks'
gem 'uglifier'
gem 'kaminari'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'minitest'
end

group :development do
  gem 'listen', '~> 3.2'
  gem 'reek', require: false
  gem 'rubocop', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubycritic', require: false
  gem 'solargraph', '~> 0.39', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
