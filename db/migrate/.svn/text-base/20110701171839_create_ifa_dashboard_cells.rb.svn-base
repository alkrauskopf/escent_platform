class CreateIfaDashboardCells < ActiveRecord::Migration
  def self.up
    create_table :ifa_dashboard_cells do |t|
      t.integer :ifa_dashboard_id
      t.integer :act_master_id
      t.integer :act_score_range_id
      t.integer :act_standard_id
      t.integer :answers_given
      t.integer :points_earned

      t.timestamps
    end
  end

  def self.down
    drop_table :ifa_dashboard_cells
  end
end
