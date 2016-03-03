class AuthorizationIndexOldId < ActiveRecord::Migration
  def self.up
    add_index :authorizations, [:old_level_id], :name=>'old_level'
  end

  def self.down
    remove_index :authorizations, [:old_level_id]
  end
end
