class DropPermissionTables < ActiveRecord::Migration
  def self.up
    drop_table :permissions
    drop_table :permission_types
  end

  def self.down
  end
end
