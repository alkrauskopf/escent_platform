class AuthorizationNewIndexes < ActiveRecord::Migration
  def self.up
    remove_index :authorizations, :user_id
    add_index :authorizations, [:user_id, :authorization_level_id, :scope_type, :scope_id], :name=>'user_level_scope'
    add_index :authorizations, [:authorization_level_id, :scope_type, :scope_id], :name=>'level_scope'
    add_index :authorizations, [:scope_type, :scope_id, :authorization_level_id], :name=>'scope_level'
  end

  def self.down
    remove_index :authorizations, [:user_id, :authorization_level_id, :scope_type, :scope_id]
    remove_index :authorizations, [:authorization_level_id, :scope_type, :scope_id]
    remove_index :authorizations, [:scope_type, :scope_id, :authorization_level_id]
    add_index :authorizations, :user_id
  end
end
