class CreateAuthorizationLevelsRolesTable < ActiveRecord::Migration
  def self.up
    create_table :authorization_levels_roles, :id => false, :force => true do |t|
      t.integer  :authorization_level_id, :null => false
      t.integer  :role_id,                :null => false
      t.datetime :created_at
    end
  
    add_index :authorization_levels_roles, [:authorization_level_id, :role_id], :name => "index_authorization_level_id_and_role_id", :unique => true
    add_index :authorization_levels_roles, [:role_id, :authorization_level_id], :name => "index_role_id_and_authorization_level_id", :unique => true
  end

  def self.down
    drop_table :authorization_levels_roles
  end
end
