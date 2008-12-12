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
  :session_key => '_myousica_sess',
  :session_domain => 'myousica.adelao.it',
  :secret      => 'eec1655098f49587abd17cb7a83c3cfa9fbec766'
}

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
config.action_mailer.delivery_method = :staging
config.action_mailer.default_content_type = 'text/html'

module ::ActionMailer
  class Base
    def perform_delivery_staging(mail)
      mail.to = 'staging@myousica.com'
      mail.cc = mail.bcc = ''
      perform_delivery_sendmail(mail)
    end
  end
end

APPLICATION = {
  :url => 'http://myousica.adelao.it',
  :email => 'no-reply@myousica.adelao.it',
  :fms_url => 'rtmp://myousica.adelao.it/live/',
  :media_url => 'http://myousica.adelao.it',
  :audio_url => '/audio',
  :video_url => '/videos',
  :media_path => '/srv/rails/myousica/shared/audio'
}
