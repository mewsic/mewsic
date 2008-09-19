# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true
config.action_controller.session = {
  :session_key => '_myousica_session_key',
  :secret      => '02cedf3882e78b5a99c0bec5cc75c3fc'
}

config.action_view.cache_template_extensions         = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
config.action_mailer.default_content_type = 'text/html'
config.action_mailer.delivery_method = :sendmail

APPLICATION = {
  :url => 'http://localhost:3000',
  :email => 'no-reply@myousica.com',
  :fms_url => 'http://localhost:3000',
  :media_url => 'http://localhost:3001',
  :audio_url => '/audio',
  :video_url => '/videos',
  :media_path => File.join(RAILS_ROOT, 'public', 'audio')
}
