# Load the Rails application.
require File.expand_path('../application', __FILE__)

unless Rails.env.test?
  ENV['FACEBOOK_ID'] = '1436853629883247'
  ENV['FACEBOOK_SECRET'] = '21af1c5e460c9c4142292c9a3e15f799'
end

# Initialize the Rails application.
Rails.application.initialize!
