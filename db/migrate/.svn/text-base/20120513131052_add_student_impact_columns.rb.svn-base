class AddStudentImpactColumns < ActiveRecord::Migration
  def self.up

   add_column :tl_student_involvements, :measure, :string, :limit => 10
   add_column :tlt_session_logs, :impact_score, :integer
   add_column :tlt_session_logs, :involve_score, :integer
   add_column :tlt_session_logs, :impact, :string
   
  end

  def self.down

   remove_column :tl_student_involvements, :measure
   remove_column :tlt_session_logs, :impact_score
   remove_column :tlt_session_logs, :involve_score
   remove_column :tlt_session_logs, :impact
   
  end
end
