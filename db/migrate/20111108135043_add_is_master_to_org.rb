class AddIsMasterToOrg < ActiveRecord::Migration
  def self.up
   add_column :organizations, :is_default, :boolean
   execute "UPDATE organizations SET is_default = 0"

  end

  def self.down

   remove_column :organizations, :is_default

  end
end
