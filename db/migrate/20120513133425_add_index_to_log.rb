class AddIndexToLog < ActiveRecord::Migration
  def self.up

    add_index :tlt_session_logs, :involve_score
    add_index :tlt_session_logs, :impact_score

  end

  def self.down

    remove_index :tlt_session_logs, :involve_score
    remove_index :tlt_session_logs, :impact_score

  end
end
