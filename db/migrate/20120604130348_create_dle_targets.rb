class CreateDleTargets < ActiveRecord::Migration
  def self.up
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

  def self.down
    drop_table :dle_targets
  end
end
