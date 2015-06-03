class CreateDleMetrics < ActiveRecord::Migration
  def self.up
    create_table :dle_metrics do |t|
      t.string :abbrev, :limit => 5
      t.string :name
      t.string :purpose
      t.string :units

      t.timestamps
    end
  end

  def self.down
    drop_table :dle_metrics
  end
end
