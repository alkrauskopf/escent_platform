class UpdateIfaDashboardAttributes < ActiveRecord::Migration
  def self.up

    remove_column :ifa_dashboards, :duration
    remove_column :ifa_dashboards, :answers_given
    remove_column :ifa_dashboards, :points_earned    
    add_column :ifa_dashboards, :finalized_assessments, :integer
    add_column :ifa_dashboards, :calibrated_assessments, :integer
    add_column :ifa_dashboards, :finalized_answers, :integer
    add_column :ifa_dashboards, :calibrated_answers, :integer
    add_column :ifa_dashboards, :finalized_points, :integer
    add_column :ifa_dashboards, :calibrated_points, :integer
    add_column :ifa_dashboards, :finalized_duration, :integer
    add_column :ifa_dashboards, :calibrated_duration, :integer
    add_column :ifa_dashboards, :calibrated_submission_answers, :integer    
  end

  def self.down

    add_column :ifa_dashboards, :duration, :integer
    add_column :ifa_dashboards, :answers_given, :integer
    add_column :ifa_dashboards, :points_earned, :integer    
    remove_column :ifa_dashboards, :finalized_assessments
    remove_column :ifa_dashboards, :calibrated_assessments
    remove_column :ifa_dashboards, :finalized_answers
    remove_column :ifa_dashboards, :calibrated_answers
    remove_column :ifa_dashboards, :finalized_points
    remove_column :ifa_dashboards, :calibrated_points
    remove_column :ifa_dashboards, :finalized_duration
    remove_column :ifa_dashboards, :calibrated_duration
    remove_column :ifa_dashboards, :calibrated_submission_answers     
  end
end
