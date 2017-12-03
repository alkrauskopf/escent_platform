class CreateIfaPlanMetricCells < ActiveRecord::Migration
  def change
    create_table :ifa_plan_metric_cells do |t|
      t.integer :ifa_plan_metric_id
      t.string :cell, :limit=>10
      t.integer :plans, :default=>0
      t.integer :in_process, :default=>0
      t.integer :acheived, :default=>0
      t.integer :remarks, :default=>0
      t.integer :evidences, :default=>0

      t.timestamps
    end
    add_index :ifa_plan_metric_cells, [:ifa_plan_metric_id, :cell], :name=>'metric_cell'
  end
end
