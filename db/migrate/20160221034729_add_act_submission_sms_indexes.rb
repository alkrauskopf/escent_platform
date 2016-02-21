class AddActSubmissionSmsIndexes < ActiveRecord::Migration
  def self.up
    add_index :act_submission_sms, [:act_submission_id, :act_master_id], :name => 'submission_standard'
    add_index :act_submission_sms, [:act_master_id], :name => 'standard'
  end

  def self.down
  end
end
