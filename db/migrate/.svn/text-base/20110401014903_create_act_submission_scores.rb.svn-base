class CreateActSubmissionScores < ActiveRecord::Migration
  def self.up
    create_table :act_submission_scores do |t|
      t.integer :act_submission_id
      t.integer :act_master_id
      t.integer :est_sms
      t.integer :final_sms

      t.timestamps
    end
  end

  def self.down
    drop_table :act_submission_scores
  end
end
