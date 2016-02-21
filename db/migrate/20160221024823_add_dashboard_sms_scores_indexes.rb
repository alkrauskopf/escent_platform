class AddDashboardSmsScoresIndexes < ActiveRecord::Migration
  def self.up
    add_index :ifa_dashboard_sms_scores, [:ifa_dashboard_id, :act_master_id], :name=>'dashboard_standard'
  end

  def self.down
  end
end
