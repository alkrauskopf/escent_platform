class AddStandardScoreDashboardSms < ActiveRecord::Migration
  def up
    add_column :ifa_dashboard_sms_scores, :standard_score, :integer, :default=> 0
    execute "UPDATE ifa_dashboard_sms_scores SET standard_score = sms_finalized"
  end

  def down
    remove_column :ifa_dashboard_sms_scores, :standard_score
  end
end
