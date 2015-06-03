class AddPolymorphismToRoles < ActiveRecord::Migration
  def self.up
    remove_index :roles, :name => "IDX_roles1"
    remove_index :roles, :name => "UK_FSNRoles2"
    rename_column :roles, :role_name, :name
    add_column :roles, :scope_id, :integer
    add_column :roles, :scope_type, :string
    remove_column :roles, :organization_id
    remove_column :roles, :package_id
    remove_column :roles, :module_id
    change_column :users, :password, :string
    add_index :roles, [:scope_id, :scope_type, :name]
  end

  def self.down
    remove_index :roles, [:scope_id, :scope_type, :name]
    rename_column :roles, :name, :role_name
    remove_column :roles, :scope_id, :integer
    remove_column :roles, :scope_type, :string
    add_column :roles, :organization_id, :integer
    add_column :roles, :package_id, :integer
    add_column :roles, :module_id, :integer
    change_column :users, :password, :string, :null => false
    add_index :roles, [:organization_id, :role_name], :name => "IDX_roles1"
    add_index :roles, [:organization_id, :package_id, :module_id, :role_name], :name => "UK_FSNRoles2"
  end
end
