class AddIfaQuestionLogIndexes < ActiveRecord::Migration
  def self.up
    remove_index :ifa_question_logs, [:grade_level, :csap]
    remove_index :ifa_question_logs, [:act_question_id, :act_submission_id]
    remove_index :ifa_question_logs, [:act_submission_id,:act_question_id]
    add_index :ifa_question_logs, [:user_id, :act_subject_id, :period_end, :is_calibrated], :name=>'user_subject_period_calibrated'
    add_index :ifa_question_logs, [:classroom_id, :act_subject_id, :period_end, :is_calibrated], :name=>'classroom_subject_period_calibrated'
    add_index :ifa_question_logs, [:organization_id, :act_subject_id, :period_end, :is_calibrated], :name=>'org_subject_period_calibrated'
    add_index :ifa_question_logs, [:act_assessment_id, :act_question_id, :period_end, :is_calibrated], :name=>'ass_quest_period_calibrated'
    add_index :ifa_question_logs, [:teacher_id, :act_question_id, :period_end, :is_calibrated], :name=>'teacher_quest_period_calibrated'
    add_index :ifa_question_logs, [:act_submission_id, :is_calibrated], :name=>'submission_calibrated'
    add_index :ifa_question_logs, [:act_question_id, :period_end], :name=>'question_period'
    add_index :ifa_question_logs, [:user_id, :act_question_id, :period_end], :name=>'user_question_period'
    add_index :ifa_question_logs, [:organization_id, :act_question_id, :period_end], :name=>'org_question_period'
  end

  def self.down
  end
end
