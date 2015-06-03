class ChangeDashboardCellPointsToDecimal < ActiveRecord::Migration
  def self.up

  add_column    :ifa_dashboard_cells, :fin_points, :decimal, :precision=>7, :scale=>2
  add_column    :ifa_dashboard_cells, :cal_points, :decimal, :precision=>7, :scale=>2
  end

  def self.down
 
  remove_column    :ifa_dashboard_cells, :fin_points
  remove_column    :ifa_dashboard_cells, :cal_points
  
  end
end
