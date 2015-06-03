class AddInvolvementIdToTlLog < ActiveRecord::Migration
  def self.up
    
   add_column :tlt_session_logs, :tl_student_involvement_id, :integer

    add_index :tlt_session_logs, :tl_student_involvement_id
 
  end

  def self.down
   remove_column :tlt_session_logs, :tl_student_involvement_id
  end
end
