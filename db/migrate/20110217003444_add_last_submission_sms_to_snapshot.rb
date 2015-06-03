class AddLastSubmissionSmsToSnapshot < ActiveRecord::Migration
  def self.up

    add_column :act_snapshots, :last_submission_sms, :integer
  
  end

  def self.down

    remove_column :act_snapshots, :last_submission_sms  
  
  end
end
