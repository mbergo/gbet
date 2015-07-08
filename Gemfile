source 'https://rubygems.org'

ruby "2.1.2"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.1.0'
gem 'rails_admin'
gem 'rails_config'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

gem 'bower-rails'
gem 'js-routes'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# MongoDB
gem 'mongoid', '>= 4.0.0'
gem 'bson_ext'

gem 'compass-rails'
gem 'jquery-rails'

gem 'devise'
gem 'omniauth-facebook'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
gem 'unicorn'
gem 'puma'

# Use Capistrano for deployment
#gem 'capistrano', group: :development

# Use debugger
gem 'byebug', group: [:development, :test]

gem 'resque'
gem 'resque-cleaner'
gem 'resque-retry', require: ['resque-retry', 'resque-retry/server', 'resque/failure/redis']
gem 'resque-lock-timeout'

group :test do
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'faker'
end

group :qa do
  gem 'heroku_rails_deflate'
  gem 'rails_12factor'
end

gem 'lograge'
gem 'quiet_assets'
