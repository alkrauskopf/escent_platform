class AddIfaStudentLevelsIndexes < ActiveRecord::Migration
  def self.up
    add_index :ifa_student_levels, [:user_id]
    add_index :ifa_student_levels, [:act_question_id]
    add_index :ifa_student_levels, [:act_submission_id]
    add_index :ifa_student_levels, [:act_master_id]
  end

  def self.down
  end
end
