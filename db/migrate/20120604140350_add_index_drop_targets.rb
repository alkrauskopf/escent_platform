class AddIndexDropTargets < ActiveRecord::Migration
  def self.up
    drop_table :dle_targets
    add_index :organization_dle_metrics, [:dle_metric_id, :organization_id]
  end

  def self.down
    create_table :dle_targets do |t|
      t.integer :user_dle_plan_id
      t.integer :dle_metric_id
      t.decimal :target, :precision => 7, :scale => 2, :default => 0.0
      t.decimal :actual, :precision => 7, :scale => 2, :default => 0.0
      t.string :note

      t.timestamps
    end
  add_index :dle_targets, [:user_dle_plan_id, :dle_metric_id]

  end
end
