class CreateItlSummaryStrategies < ActiveRecord::Migration
  def self.up
    create_table :itl_summary_strategies do |t|
      t.integer :itl_summary_id
      t.integer :tl_activity_type_task_id
      t.integer :duration, :default => 0
      t.integer :segments, :default => 0
      t.integer :engage_total, :default => 0
      t.integer :engage_segments, :default => 0
      t.integer :layer_effect, :default => 0

      t.timestamps
    end
    add_index :itl_summary_strategies, :itl_summary_id
    add_index :itl_summary_strategies, :tl_activity_type_task_id

  end

  def self.down
    drop_table :itl_summary_strategies
  end
end
