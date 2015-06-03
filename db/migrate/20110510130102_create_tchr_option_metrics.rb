class CreateTchrOptionMetrics < ActiveRecord::Migration
  def self.up
    create_table :tchr_option_metrics do |t|
      t.integer :tchr_option_id
      t.integer :tchr_metric_id
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :tchr_option_metrics
  end
end
