class AuthorizationLevelIndexes < ActiveRecord::Migration
  def self.up
    remove_column :authorization_levels, :parent_id
    remove_index :authorization_levels, [:name]
    remove_index :authorization_levels, [:coop_app_id]
    add_index :authorization_levels, [:coop_app_id, :name], :name =>'app_name'
    add_index :authorization_levels, [:name, :coop_app_id], :name =>'name_app'
  end

  def self.down
    remove_index :authorization_levels, [:coop_app_id, :name]
    remove_index :authorization_levels, [:name, :coop_app_id]
    add_column :authorization_levels, :parent_id, :integer
    add_index :authorization_levels, [:name]
    add_index :authorization_levels, [:coop_app_id]
  end
end
