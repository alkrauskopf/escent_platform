class AddOldLevelIdApplScopes < ActiveRecord::Migration
  def self.up
    add_column :applicable_scopes, :old_level_id, :integer
    add_index :applicable_scopes, [:old_level_id], :name=>'old_level'
  end

  def self.down
    remove_column :applicable_scopes, :old_level_id
  end
end
