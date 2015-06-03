class AddDatestampToIfaStudentLevel < ActiveRecord::Migration
  def self.up

   add_column :ifa_student_levels, :act_submission_id, :integer  
   add_column :ifa_student_levels, :submission_date, :date   
  end

  def self.down

   remove_column :ifa_student_levels, :act_submission_id
   remove_column :ifa_student_levels, :submission_date  
  
  end
end
