class CreateApplicableScopes < ActiveRecord::Migration
  def self.up
    create_table :applicable_scopes do |t|
      t.integer :authorization_level_id  
      t.string :name
      t.timestamps
    end
    add_index :applicable_scopes, [:authorization_level_id]
  end

  def self.down
    drop_table :applicable_scopes
  end
end
