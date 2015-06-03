class AddCredentialsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :credentials, :text
  end

  def self.down
    remove_column :users, :credentials
  end
end
