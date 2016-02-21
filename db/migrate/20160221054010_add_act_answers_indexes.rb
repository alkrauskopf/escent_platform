class AddActAnswersIndexes < ActiveRecord::Migration
  def self.up
    add_index :act_answers, [:organization_id]
    add_index :act_answers, [:act_submission_id, :act_question_id], :name=>'submission_question'
    add_index :act_answers, [:act_submission_id, :is_calibrated], :name=>'submission_calibrated'
    add_index :act_answers, [:act_question_id]
    add_index :act_answers, [:act_choice_id]
    add_index :act_answers, [:act_assessment_id]
    add_index :act_answers, [:user_id]
    add_index :act_answers, [:organization_id]
    add_index :act_answers, [:teacher_id]
    add_index :act_answers, [:classroom_id]
  end

  def self.down
  end
end
