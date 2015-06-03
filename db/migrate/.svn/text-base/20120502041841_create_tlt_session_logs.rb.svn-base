class CreateTltSessionLogs < ActiveRecord::Migration
  def self.up
    create_table :tlt_session_logs do |t|
      t.integer :tlt_session_id
      t.integer :tl_activity_type_task_id
      t.datetime :start_time
      t.integer :duration
      t.string :note

      t.timestamps
    end
    add_index :tlt_session_logs, :tlt_session_id
    add_index :tlt_session_logs, :tl_activity_type_task_id

  end

  def self.down
    drop_table :tlt_session_logs
  end
end
