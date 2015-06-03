class AddAlternateUserEmail < ActiveRecord::Migration
  def self.up

    add_column :users, :preferred_email, :string
    add_column :users, :alt_login, :string, :default =>""
    execute "UPDATE users SET preferred_email = email_address"
    execute "UPDATE users SET alt_login = ''"

  end

  def self.down
    remove_column :users, :preferred_email
    remove_column :users, :alt_login    
  end
end
