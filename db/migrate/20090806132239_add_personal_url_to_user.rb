class AddPersonalUrlToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :personal_url, :string
  end

  def self.down
    remove_column :users, :personal_url
  end
end
