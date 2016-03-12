class AddDashboardCellsIndexes < ActiveRecord::Migration
  def self.up
    add_index :ifa_dashboard_cells, [:ifa_dashboard_id, :act_score_range_id, :act_standard_id], :name=>'dashboard_range_strand'
    add_index :ifa_dashboard_cells, [:ifa_dashboard_id, :act_standard_id, :act_score_range_id], :name=>'dashboard_strand_range'
    add_index :ifa_dashboard_cells, [:act_master_id], :name=>'standard'
  end

  def self.down
  end
end
