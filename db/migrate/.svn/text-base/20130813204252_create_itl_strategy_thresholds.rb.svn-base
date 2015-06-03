class CreateItlStrategyThresholds < ActiveRecord::Migration
  def self.up
    create_table :itl_strategy_thresholds do |t|
      t.integer :tl_activity_type_task_id
      t.integer :max_minutes
      t.string :max_minute_msg
      t.integer :min_minutes
      t.string :min_minutes_msg
      t.integer :max_pct
      t.string :max_pct_msg
      t.integer :min_pct
      t.string :min_pct_msg

      t.timestamps
    end
  
  add_index :itl_strategy_thresholds, :tl_activity_type_task_id
  
  end

  def self.down
    drop_table :itl_strategy_thresholds
  end
end
