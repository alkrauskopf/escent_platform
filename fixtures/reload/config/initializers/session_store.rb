# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_reload_session',
  :secret      => '257de3e757eb198143642060826005cee74337c94acc1c6712b0848c58d016674f8f44ff3c97108598b0025afc75b45fdb3f4a8e81f808fb34b3c0440db63740'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
