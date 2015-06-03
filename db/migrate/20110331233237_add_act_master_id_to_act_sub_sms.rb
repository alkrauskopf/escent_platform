class AddActMasterIdToActSubSms < ActiveRecord::Migration
  def self.up

    add_column :act_submission_sms, :act_master_id, :integer
  
  end

  def self.down
    remove_column :act_submission_sms, :act_master_id  
  end
end
