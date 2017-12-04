class RenameMetricCell < ActiveRecord::Migration
  def up
    rename_column :ifa_plan_metric_cells, :acheived, :achieved
    add_index :ifa_plan_metric_cells, [:cell], :name=>'cell'
  end

  def down
    rename_column :ifa_plan_metric_cells, :achieved, :acheived
  end
end
