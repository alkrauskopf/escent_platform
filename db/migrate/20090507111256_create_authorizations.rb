class CreateAuthorizations < ActiveRecord::Migration
  def self.up
    create_table :authorizations do |t|
      t.integer      :user_id, :null => false
      t.integer      :scope_id
      t.string       :scope_type,   :limit => 32
      t.integer      :authorization_level_id,   :null => false
      t.timestamps
    end
    add_index :authorizations, [:user_id]
  end

  def self.down
    drop_table :authorizations
  end
end
