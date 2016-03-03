class AddOrigLevelIdAuthLevels < ActiveRecord::Migration
  def self.up
    add_column :authorization_levels, :old_level_id, :integer
  end

  def self.down
    remove_column :authorization_levels, :old_level_id
  end
end
