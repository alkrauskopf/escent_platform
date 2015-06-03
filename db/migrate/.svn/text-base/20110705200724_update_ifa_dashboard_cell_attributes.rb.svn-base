class UpdateIfaDashboardCellAttributes < ActiveRecord::Migration
  def self.up

    remove_column :ifa_dashboard_cells, :answers_given
    remove_column :ifa_dashboard_cells, :points_earned
    
    add_column :ifa_dashboard_cells, :finalized_answers, :integer
    add_column :ifa_dashboard_cells, :calibrated_answers, :integer  
    add_column :ifa_dashboard_cells, :finalized_points, :integer
    add_column :ifa_dashboard_cells, :calibrated_points, :integer
 end

  def self.down

    add_column :ifa_dashboard_cells, :answers_given, :integer
    add_column :ifa_dashboard_cells, :points_earned, :integer
    
    remove_column :ifa_dashboard_cells, :finalized_answers
    remove_column :ifa_dashboard_cells, :calibrated_answers  
    remove_column :ifa_dashboard_cells, :finalized_points
    remove_column :ifa_dashboard_cells, :calibrated_points  
  end
end
