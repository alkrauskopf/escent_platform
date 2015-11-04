class DropChannelTables < ActiveRecord::Migration
  def self.up
    drop_table :channels
    drop_table :channel_contents
    drop_table :channel_types
    drop_table :default_package_roles
  end

  def self.down
  end
end
