require 'logging'

# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Disable "forgery" protection
config.action_controller.allow_forgery_protection    = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
#config.action_view.cache_template_extensions         = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

config.action_mailer.delivery_method = :test
config.action_mailer.smtp_settings = {
  :address => "",
  :port => 25,
  :domain => "",
  :authentication => :login,
  :user_name => "",
  :password => ""
}

SERVER_NAME = "localhost:3000"


Logging.init :debug, :info, :warn, :error, :fatal

layout = Logging::Layouts::Pattern.new :pattern => "[%d] [%-5l] %m\n"

# Default logfile, history kept for 10 days
default_appender = Logging::Appenders::RollingFile.new 'default', \
  :filename => 'log/development.log', :age => 'daily', :keep => 10, :safe => true, :layout => layout

DEFAULT_LOGGER = Logging::Logger['server']
DEFAULT_LOGGER.add_appenders default_appender

# When using "script/server mongrel", use
RAILS_DEFAULT_LOGGER = DEFAULT_LOGGER
# instead
# config.logger = DEFAULT_LOGGER

DEFAULT_LOGGER.level = :debug
config.log_level = :debug