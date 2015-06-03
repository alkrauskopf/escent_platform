class AddTlLogIndex < ActiveRecord::Migration
  def self.up
    add_index :tlt_session_logs, [:tlt_session_id, :tl_activity_type_task_id], :name => "session_log_task"
  end

  def self.down
    remove_index :tlt_session_logs, [:tlt_session_id, :tl_activity_type_task_id], :name => "session_log_task"
  end
end
