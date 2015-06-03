class AddIsManualTltSession < ActiveRecord::Migration
  def self.up

    add_column :tlt_sessions, :session_date, :date
    add_column :tlt_sessions, :is_manual, :boolean
    execute "UPDATE tlt_sessions SET is_manual = 0"
    execute "UPDATE tlt_sessions SET session_date = created_at"   
  end

  def self.down

    remove_column :tlt_sessions, :session_date
    remove_column :tlt_sessions, :is_manual

  end
end
