class CreateTlStrategyDescripts < ActiveRecord::Migration
  def self.up
    create_table :tl_strategy_descripts do |t|
      t.integer :tl_activity_type_task_id
      t.text :description
      t.text :research

      t.timestamps
    end
    add_index :tl_strategy_descripts , :tl_activity_type_task_id, :name => "strategy"

  end

  def self.down
    drop_table :tl_strategy_descripts
  end
end
