class AddCellDashboardCell < ActiveRecord::Migration
  def up
    add_column :ifa_dashboard_cells, :cell, :string, :limit=>10

    add_index :ifa_dashboard_cells, [:ifa_dashboard_id]
    add_index :ifa_dashboard_cells, [:ifa_dashboard_id, :cell]

  end

  def down
    remove_column :ifa_dashboard_cells, :cell, :string
  end
end
