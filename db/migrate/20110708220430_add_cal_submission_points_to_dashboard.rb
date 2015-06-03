class AddCalSubmissionPointsToDashboard < ActiveRecord::Migration
  def self.up

   add_column :ifa_dashboards, :calibrated_submission_points, :integer
  
  end

  def self.down

   remove_column :ifa_dashboards, :calibrated_submission_points  
  end
end
