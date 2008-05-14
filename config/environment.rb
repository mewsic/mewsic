# Be sure to restart your server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named.
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  config.action_controller.session = {
    :session_key => '_myousica_session_key',
    :secret      => '02cedf3882e78b5a99c0bec5cc75c3fc'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer, :friendship_observer

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # See Rails::Configuration for more options

  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded
end

# Allow few html tags to sanitize()
ActionView::Base.sanitized_allowed_tags.clear
ActionView::Base.sanitized_allowed_tags = *%w(strong em b i code small address ul li abbr br)

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance| 
  "<span class=\"fieldWithErrors\">#{html_tag}</span><span class=\"error\"><img src=\"/images/alert_ico.gif\" alt="" /> #{[instance.error_message].flatten.first}</span>"
#  %{<div class="error-with-field">#{html} <small class="error">&bull; #{[instance.error_message].flatten.first}</small></div>}  
end

ExceptionNotifier.exception_recipients = %w(franz.andrea@gmail.com)
ExceptionNotifier.sender_address = %("Myousica Application Error" <error@myousica.com>)
ExceptionNotifier.email_prefix = "[MYOUSICA ERROR] "
