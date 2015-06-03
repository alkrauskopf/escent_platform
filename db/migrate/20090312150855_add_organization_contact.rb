class AddOrganizationContact < ActiveRecord::Migration
  def self.up
    add_column :organizations, :contact_name, :string
    add_column :organizations, :contact_role, :string
    
  end

  def self.down
    remove_column :organizations, :contact_name
    remove_column :organizations, :contact_role
  end
end
