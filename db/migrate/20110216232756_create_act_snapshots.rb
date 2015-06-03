class CreateActSnapshots < ActiveRecord::Migration
  def self.up
    create_table :act_snapshots do |t|
      t.integer :user_id
      t.integer :act_subject_id
      t.integer :last_submission_id
      t.integer :current_sms_level
      t.timestamp :last_submission_date

      t.timestamps
    end
  end

  def self.down
    drop_table :act_snapshots
  end
end
