# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_fixtures:reload_session',
  :secret      => 'af3c33bb7fa31c5714edc496aa5fd13e311fbfd0e6e28f491a89de959460e8556c950887067edabb31267ecfed1ab5c471234d8d9163d9118457d9d4eb832d18'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
