class RemoveColsFromDashboardCell < ActiveRecord::Migration
  def self.up

   remove_column :ifa_dashboard_cells, :finalized_points
   remove_column :ifa_dashboard_cells, :calibrated_points
   
  end

  def self.down

   add_column :ifa_dashboard_cells, :finalized_points, :integer
   add_column :ifa_dashboard_cells, :calibrated_points, :integer
   
  end
end
