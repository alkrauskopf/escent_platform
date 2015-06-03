class RenameAssociatedOrganizations < ActiveRecord::Migration
  def self.up
    rename_table :associated_organizations, :organizations_users
    add_index :organizations_users, [:organization_id, :user_id], :unique => true
    add_index :organizations_users, [:user_id, :organization_id], :unique => true
    remove_column :organizations_users, :id
  end

  def self.down
    add_index :organizations_users, [:organization_id, :user_id], :unique => true
    add_index :organizations_users, [:user_id, :organization_id], :unique => true
    add_column :organizations_users, :id, :integer, :null => false, :primary_key => true
    rename_table :organizations_users, :associated_organizations
  end
end
