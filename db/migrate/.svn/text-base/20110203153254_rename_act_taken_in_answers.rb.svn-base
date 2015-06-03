class RenameActTakenInAnswers < ActiveRecord::Migration
  def self.up
    rename_column :act_answers, :act_taken_assessment_id, :act_submission_id
  end

  def self.down
    rename_column :act_answers, :act_submission_id, :act_taken_assessment_id
  end
end
