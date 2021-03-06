# Be sure to restart your server when you modify this file

# recapctha keys
ENV['RECAPTCHA_PUBLIC_KEY']  = '6Lc-jgsAAAAAABY6ISjEe1nhK1V-rbt4zqTk-pFv'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6Lc-jgsAAAAAAHs-P6ccwRLQw7tJz3vR5FQS1X_h'
  
# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '2.0.4' unless defined? RAILS_GEM_VERSION
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %W( #{RAILS_ROOT}/lib/body_size )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_Bodysize_session_id',
    :secret      => 'd2868f8cd6ce59a412ebfdd9998d1dba365def0058e6e81399c6f9ac27b89e0796293c2c8b8799a04f8c2cfe3340feb509967f90501e32ebd81dac71c0b7a546'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
end


#Documentation - http://internetducttape.com/2008/02/06/rails-guide-exception-notifier-plugin/
#update email to lead developer on project
ExceptionNotifier.exception_recipients = %w(developers@scimedsolutions.com)
ExceptionNotifier.sender_address = %("Bodysize Application Error" <no-reply@scimedsolutions.com>)   
# defaults to "[ERROR] "   
ExceptionNotifier.email_prefix = "[Bodysize] "

require 'body_size/error'
require "will_paginate"
require "remote_link_renderer"