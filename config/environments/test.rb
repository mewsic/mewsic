# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_controller.session = {
  :session_key => '_myousica_sess',
  :secret      => '1ad6c4dd41760f8b5bb6012bfccef2c038e0931f'
}

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

APPLICATION = {
  :url => 'http://localhost:3000',
  :email => 'no-reply@myousica.com',
  :fms_url => 'rtmp://localhost:3000',
  :media_url => 'http://localhost:3001',
  :audio_url => '/audio',
  :video_url => '/videos',
  :media_path => File.join(RAILS_ROOT, 'test', 'fixtures', 'files')
}
