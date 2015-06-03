class AddInvolvementToSessionLog < ActiveRecord::Migration
  def self.up
     add_column :tlt_session_logs, :involve, :text
  end

  def self.down
     remove_column :tlt_session_logs, :involve
  end
end
