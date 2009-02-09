require 'logging'

# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
#config.action_view.cache_template_loading            = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable "forgery" protection
config.action_controller.allow_forgery_protection    = false

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false


config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  :address => "smtp.nescent.org",
  :port => 25
  #:domain => "darwin.nescent.org"
}

config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = false

SERVER_NAME = "darwin.nescent.org"


Logging.init :debug, :info, :warn, :error, :fatal

layout = Logging::Layouts::Pattern.new :pattern => "[%d] [%-5l] %m\n"

# Default logfile, history kept for 10 days
default_appender = Logging::Appenders::RollingFile.new 'default', \
  :filename => 'log/production.log', :age => 'daily', :keep => 10, :safe => true, :layout => layout

DEFAULT_LOGGER = Logging::Logger['server']
DEFAULT_LOGGER.add_appenders default_appender

# When using "script/server mongrel", use
RAILS_DEFAULT_LOGGER = DEFAULT_LOGGER
# instead
# config.logger = DEFAULT_LOGGER

DEFAULT_LOGGER.level = :debug
config.log_level = :debug