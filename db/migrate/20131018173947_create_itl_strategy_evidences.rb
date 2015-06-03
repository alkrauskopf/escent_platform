class CreateItlStrategyEvidences < ActiveRecord::Migration
  def self.up
    create_table :itl_strategy_evidences do |t|
      t.integer :tl_activity_type_task_id
      t.integer :evidence_id

      t.timestamps
    end
    add_index :itl_strategy_evidences, :tl_activity_type_task_id
    add_index :itl_strategy_evidences, :evidence_id
  end

  def self.down
    drop_table :itl_strategy_evidences
  end
end
