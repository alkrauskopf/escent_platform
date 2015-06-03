# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_model_session',
  :secret      => '276c7853d57a063cf93398a18758fa555c2f87971af8ede01c436c19277aa884bb18f17f81405edc54c911293ca7cc1c456355cb257eaf6a7ba9ebb808cb8648'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
