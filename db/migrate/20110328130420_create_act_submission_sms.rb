class CreateActSubmissionSms < ActiveRecord::Migration
  def self.up
    create_table :act_submission_sms do |t|
      t.integer :act_submission_id
      t.string :standard
      t.integer :est_sms
      t.integer :final_sms
      t.integer :upper_score_bound
      t.integer :lower_score_bound

      t.timestamps
    end
  end

  def self.down
    drop_table :act_submission_sms
  end
end
