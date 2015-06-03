class CreateIfaStudentLevels < ActiveRecord::Migration
  def self.up
    create_table :ifa_student_levels do |t|
      t.integer :act_question_id
      t.integer :act_master_id
      t.integer :user_id
      t.integer :mastery_level
      t.integer :calibrated_mastery_level
      t.integer :choices
      t.integer :points

      t.timestamps
    end
  end

  def self.down
    drop_table :ifa_student_levels
  end
end
