# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Enable threaded mode
# config.threadsafe!

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

MAIL_SMTP_SERVER = 'mail.escentpartners.com'
MAIL_SMTP_DOMAIN = 'escentpartners.com'
MAIL_SMTP_USERNAME = 'smtpsender@escentpartners.com'
MAIL_SMTP_PASSWORD = 'h939thbnsf22'

config.action_mailer.smtp_settings = {
  :address          => MAIL_SMTP_SERVER,
  :domain           => MAIL_SMTP_DOMAIN,
  :authentication   => :login,
  :user_name        => MAIL_SMTP_USERNAME,
  :password         => MAIL_SMTP_PASSWORD
}


AUTHENTICATION_HOST = "www.escentpartners.com"
