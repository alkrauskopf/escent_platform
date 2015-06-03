class RemoveIsSuspendedFromOrg < ActiveRecord::Migration
  def self.up
   remove_column :organizations, :is_suspended
  end

  def self.down
   add_column :organizations, :is_suspended, :boolean
   execute "UPDATE organizations SET is_suspended = 0"
  end
end
