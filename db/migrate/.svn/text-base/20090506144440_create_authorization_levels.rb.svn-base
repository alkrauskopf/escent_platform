class CreateAuthorizationLevels < ActiveRecord::Migration
  def self.up
    create_table :authorization_levels do |t|
      t.integer   :parent_id
      t.string    :name,        :null => false
      t.string    :description, :limit => 1000
      t.timestamps
    end
    add_index :authorization_levels, [:name], :unique => true
    
    create_table :authorization_levels_users, :id => false do |t|
      t.integer   :authorization_level_id,    :null => false
      t.integer   :user_id,                   :null => false
      t.datetime  :created_at
    end
    add_index :authorization_levels_users, [:authorization_level_id, :user_id], :name => "index_authorization_level_id_and_user_id", :unique => true
    add_index :authorization_levels_users, [:user_id, :authorization_level_id], :name => "index_user_id_and_authorization_level_id", :unique => true
  end

  def self.down
    drop_table :authorization_levels
    drop_table :authorization_levels_users
  end
end
