class AddTltSessionDuration < ActiveRecord::Migration
  def self.up


  add_column :tlt_sessions, :session_duration, :integer, :default=> 0
  execute "UPDATE tlt_sessions SET session_duration = duration" 

  end

  def self.down

  remove_column :tlt_sessions, :session_duration

  end
end
