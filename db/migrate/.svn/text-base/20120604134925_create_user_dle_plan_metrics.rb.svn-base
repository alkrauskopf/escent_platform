class CreateUserDlePlanMetrics < ActiveRecord::Migration
  def self.up
    create_table :user_dle_plan_metrics do |t|
      t.integer :user_dle_plan_id
      t.integer :dle_metric_id
      t.decimal :target, :precision => 7, :scale => 2, :default => 0.0
      t.decimal :actual, :precision => 7, :scale => 2, :default => 0.0
      t.string :note

      t.timestamps
    end
  end

  def self.down
    drop_table :user_dle_plan_metrics
  end
end
