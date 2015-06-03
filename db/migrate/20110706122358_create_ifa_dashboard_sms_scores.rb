class CreateIfaDashboardSmsScores < ActiveRecord::Migration
  def self.up
    create_table :ifa_dashboard_sms_scores do |t|
      t.integer :ifa_dashboard_id
      t.integer :act_master_id
      t.integer :score_range_min
      t.integer :score_range_max
      t.integer :sms_finalized
      t.integer :sms_calibrated

      t.timestamps
    end
  end

  def self.down
    drop_table :ifa_dashboard_sms_scores
  end
end
