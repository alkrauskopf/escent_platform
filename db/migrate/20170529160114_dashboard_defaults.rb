class DashboardDefaults < ActiveRecord::Migration
  def up
    change_column :ifa_dashboards, :assessments_taken, :integer, :default=>0
    change_column :ifa_dashboards, :finalized_assessments, :integer, :default=>0
    change_column :ifa_dashboards, :calibrated_assessments, :integer, :default=>0
    change_column :ifa_dashboards, :finalized_answers, :integer, :default=>0
    change_column :ifa_dashboards, :calibrated_answers, :integer, :default=>0
    change_column :ifa_dashboards, :finalized_duration, :integer, :default=>0
    change_column :ifa_dashboards, :calibrated_duration, :integer, :default=>0
    change_column :ifa_dashboards, :fin_points, :decimal, :precision => 7, :scale => 2, :default=>0.0
    change_column :ifa_dashboards, :cal_points, :decimal, :precision => 7, :scale => 2, :default=>0.0
    change_column :ifa_dashboards, :cal_submission_points, :decimal, :precision => 7, :scale => 2, :default=>0.0
    change_column :ifa_dashboards, :cal_submission_answers, :integer, :default=>0

    change_column :ifa_dashboard_sms_scores, :score_range_min, :integer, :default=>0
    change_column :ifa_dashboard_sms_scores, :score_range_max, :integer, :default=>0
    change_column :ifa_dashboard_sms_scores, :sms_finalized, :integer, :default=>0
    change_column :ifa_dashboard_sms_scores, :sms_calibrated, :integer, :default=>0

    change_column :ifa_dashboard_cells, :finalized_answers, :integer, :default=>0
    change_column :ifa_dashboard_cells, :calibrated_answers, :integer, :default=>0
    change_column :ifa_dashboard_cells, :fin_points, :decimal, :precision => 7, :scale => 2, :default=>0.0
    change_column :ifa_dashboard_cells, :cal_points, :decimal, :precision => 7, :scale => 2, :default=>0.0
  end

  def down
    change_column :ifa_dashboards, :assessments_taken, :integer, :default=>0
    change_column :ifa_dashboards, :finalized_assessments, :integer, :default=>0
    change_column :ifa_dashboards, :calibrated_assessments, :integer, :default=>0
    change_column :ifa_dashboards, :finalized_answers, :integer, :default=>0
    change_column :ifa_dashboards, :calibrated_answers, :integer, :default=>0
    change_column :ifa_dashboards, :finalized_duration, :integer, :default=>0
    change_column :ifa_dashboards, :calibrated_duration, :integer, :default=>0
    change_column :ifa_dashboards, :fin_points, :decimal, :precision => 7, :scale => 2, :default=>0.0
    change_column :ifa_dashboards, :cal_points, :decimal, :precision => 7, :scale => 2, :default=>0.0
    change_column :ifa_dashboards, :cal_submission_points, :decimal, :precision => 7, :scale => 2, :default=>0.0
    change_column :ifa_dashboards, :cal_submission_answers, :integer, :default=>0

    change_column :ifa_dashboard_sms_scores, :score_range_min, :integer, :default=>0
    change_column :ifa_dashboard_sms_scores, :score_range_max, :integer, :default=>0
    change_column :ifa_dashboard_sms_scores, :sms_finalized, :integer, :default=>0
    change_column :ifa_dashboard_sms_scores, :sms_calibrated, :integer, :default=>0

    change_column :ifa_dashboard_cells, :finalized_answers, :integer, :default=>0
    change_column :ifa_dashboard_cells, :calibrated_answers, :integer, :default=>0
    change_column :ifa_dashboard_cells, :fin_points, :decimal, :precision => 7, :scale => 2, :default=>0.0
    change_column :ifa_dashboard_cells, :cal_points, :decimal, :precision => 7, :scale => 2, :default=>0.0
  end
end
