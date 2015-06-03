class RemoveColsFromDashboard < ActiveRecord::Migration
  def self.up

   remove_column :ifa_dashboards, :finalized_points
   remove_column :ifa_dashboards, :calibrated_points
   remove_column :ifa_dashboards, :calibrated_submission_points
   remove_column :ifa_dashboards, :calibrated_submission_answers
   
  end

  def self.down

   add_column :ifa_dashboards, :finalized_points, :integer
   add_column :ifa_dashboards, :calibrated_points, :integer
   add_column :ifa_dashboards, :calibrated_submission_points, :integer
   add_column :ifa_dashboards, :calibrated_submission_answers, :integer
   
  end
end
