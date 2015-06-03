class RenameSessionDuration < ActiveRecord::Migration
  def self.up
  rename_column :tlt_sessions, :session_duration, :session_length
  end

  def self.down
  rename_column :tlt_sessions, :session_length, :session_duration
  end
end
