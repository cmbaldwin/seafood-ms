# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password]
Rails.application.config.filter_parameters += [:data]
Rails.application.config.filter_parameters += [:access_token]
Rails.application.config.filter_parameters += [:authorization_code]
