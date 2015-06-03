class CreateAuthorizableActions < ActiveRecord::Migration
  def self.up
    create_table :authorizable_actions do |t|
      t.integer        :authorization_level_id,  :null => false
      t.string         :name,  :limit => 64, :null => false
      t.timestamps
    end
    add_index :authorizable_actions, [:authorization_level_id, :name], :unique => true
  end

  def self.down
    drop_table :authorizable_actions
  end
end
