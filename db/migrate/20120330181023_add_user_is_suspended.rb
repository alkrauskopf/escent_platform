class AddUserIsSuspended < ActiveRecord::Migration
  def self.up

   add_column :users, :is_suspended, :boolean
   execute "UPDATE users SET is_suspended = 0"

  end

  def self.down

   remove_column :users, :is_suspended

  end
end
