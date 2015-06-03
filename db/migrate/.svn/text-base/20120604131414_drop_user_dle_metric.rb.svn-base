class DropUserDleMetric < ActiveRecord::Migration
  def self.up
    drop_table :user_dle_metrics
  end

  def self.down
    create_table :user_dle_metrics do |t|
      t.integer :user_id
      t.integer :dle_cycle_id
      t.integer :tchr_metric_id
      t.decimal :target, :precision => 7, :scale => 2, :default => 0.0
      t.decimal :actual, :precision => 7, :scale => 2, :default => 0.0
      t.text :comment
      t.date :date_finalized

      t.timestamps
    end
  add_index :user_dle_metrics, [:user_id, :dle_cycle_id]
  add_index :user_dle_metrics, :tchr_metric_id
  add_index :user_dle_metrics, :date_finalized

  end
end
