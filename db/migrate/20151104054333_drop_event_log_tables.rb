class DropEventLogTables < ActiveRecord::Migration
  def self.up
    drop_table :event_log_types
    drop_table :event_logs
  end

  def self.down
  end
end
