class CreateIfaQuestionLogs < ActiveRecord::Migration
  def self.up
    create_table :ifa_question_logs do |t|
      t.integer :act_question_id
      t.integer :act_assessment_id
      t.integer :act_submission_id
      t.integer :user_id
      t.integer :organziation_id
      t.integer :classroom_id
      t.integer :teacher_id
      t.integer :act_subject_id
      t.date :date_taken
      t.boolean :is_calibrated
      t.decimal :points
      t.integer :choices

      t.timestamps
    end
    
    add_index "ifa_question_logs", ["user_id", "act_subject_id", "is_calibrated", "date_taken"]
    add_index "ifa_question_logs", ["organization_id", "act_subject_id", "is_calibrated", "date_taken"]
    add_index "ifa_question_logs", ["classroom_id", "act_subject_id", "is_calibrated", "date_taken"]
    add_index "ifa_question_logs", ["teacher_id", "act_subject_id", "is_calibrated", "date_taken"]    
    add_index "ifa_question_logs", ["act_assessment_id", "date_taken"]
    add_index "ifa_question_logs", ["act_submission_id"]
    
  end

  def self.down
    drop_table :ifa_question_logs
  end
end
