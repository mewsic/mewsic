# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
config.action_mailer.delivery_method = :smtp
config.action_mailer.default_content_type = 'text/html'
config.action_mailer.smtp_settings = {
  :address => 'smtp',
  :port => 25,
  :domain => 'myousica.com'
}

# Attachments on EY
ENV['INLINEDIR'] = "/tmp/#{$$}"

APPLICATION = {
  :url => 'http://e4e1475b.myousica.com',
  :email => 'no-reply@myousica.com',
  :fms_url => 'rtmp://fms.myousica.com/',
  :media_url => 'upload.myousica.com/'
}
