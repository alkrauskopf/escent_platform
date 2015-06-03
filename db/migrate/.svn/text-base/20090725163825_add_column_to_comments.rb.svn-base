class AddColumnToComments < ActiveRecord::Migration
  def self.up
    add_column :comments , :user_name , :string
    add_column :comments , :user_url  , :string
    add_column :comments , :user_email , :string
  end

  def self.down
    remove_column :comments , :user_name
    remove_column :comments , :user_url
    remove_column :comments , :user_email
  end
end
