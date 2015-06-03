class AddNotficationOrganization < ActiveRecord::Migration
  def self.up
   add_column :organizations, :register_notify, :boolean
   execute "UPDATE organizations SET register_notify = 0"
  end

  def self.down
   remove_column :organizations, :register_notify
  end
end
