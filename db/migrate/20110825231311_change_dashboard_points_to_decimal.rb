class ChangeDashboardPointsToDecimal < ActiveRecord::Migration
  def self.up

  add_column    :ifa_dashboards, :fin_points, :decimal, :precision=>7, :scale=>2
  add_column    :ifa_dashboards, :cal_points, :decimal, :precision=>7, :scale=>2
  add_column    :ifa_dashboards, :cal_submission_points, :decimal, :precision=>7, :scale=>2
  add_column    :ifa_dashboards, :cal_submission_answers, :integer
  
  end

  def self.down

  remove_column    :ifa_dashboards, :fin_points
  remove_column    :ifa_dashboards, :cal_points
  remove_column    :ifa_dashboards, :cal_submission_points
  remove_column    :ifa_dashboards, :cal_submission_answers  
  end
end
