class AddStandardScoreCalDashboardSms < ActiveRecord::Migration
  def up
    add_column :ifa_dashboard_sms_scores, :standard_score_cal, :integer, :default=> 0
    execute "UPDATE ifa_dashboard_sms_scores SET standard_score_cal = sms_calibrated"
  end

  def down
    remove_column :ifa_dashboard_sms_scores, :standard_score_cal
  end
end
