# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
config.action_controller.session = {
  :session_key => '_mewsic_sess',
  :session_domain => '.mewsic.com',
  :secret      => 'b0bf476cf838ea5bdb60fcce1209d412c01d631f'
}

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
config.action_mailer.delivery_method = :smtp
config.action_mailer.default_content_type = 'text/html'
config.action_mailer.smtp_settings = {
  :address => 'smtp',
  :port => 25,
  :domain => 'mewsic.com'
}

# Attachments on EY
ENV['INLINEDIR'] = "/tmp/#{$$}"

APPLICATION = {
  :url => 'http://mewsic.com',
  :email => 'no-reply@mewsic.com',
  :fms_url => 'rtmp://upload.mewsic.com/',
  :media_url => 'http://upload.mewsic.com/',
  :audio_url => '/audio',
  :video_url => '/videos',
  :media_path => '/srv/rails/mewsic/shared/audio'
}
