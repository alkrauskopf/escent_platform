class AddIsSuspendedOrg < ActiveRecord::Migration
  def self.up
   add_column :organizations, :is_suspended, :boolean
   execute "UPDATE organizations SET is_suspended = 0"
  end

  def self.down
   remove_column :organizations, :is_suspended
  end
end
