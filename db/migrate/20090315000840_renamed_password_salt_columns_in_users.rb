class RenamedPasswordSaltColumnsInUsers < ActiveRecord::Migration
  def self.up
    rename_column :users, :password_salt, :salt
    rename_column :users, :is_age_verified, :age_verified
    rename_column :users, :is_tos_read, :read_tos
    add_column    :users, :updated_at, :datetime
  end

  def self.down
    rename_column :users, :salt, :password_salt
    rename_column :users, :age_verified, :is_age_verified
    rename_column :users, :read_tos, :is_tos_read
    remove_column    :users, :updated_at, :datetime
  end
end
