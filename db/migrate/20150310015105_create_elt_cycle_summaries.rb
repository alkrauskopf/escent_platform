class CreateEltCycleSummaries < ActiveRecord::Migration
  def self.up
    create_table :elt_cycle_summaries do |t|
      t.integer :elt_cycle_id
      t.integer :elt_indicator_id
      t.integer :elt_type_id
      t.string :cycle
      t.string :activity
      t.string :element
      t.string :indicator
      t.integer :school_count, :default => 0
      t.decimal :rating, :precision => 6, :scale => 3, :default => 0.0

      t.timestamps
    end
    add_index :elt_cycle_summaries, [:elt_indicator_id, :elt_cycle_id, :elt_type_id], :name => "indicator_cycle_activity"
    add_index :elt_cycle_summaries, [:elt_cycle_id, :elt_indicator_id, :elt_type_id], :name => "cycle_indicator_activity"
    add_index :elt_cycle_summaries, [:elt_type_id, :elt_indicator_id, :elt_cycle_id, ], :name => "activity_indicator_cycle"
  end

  def self.down
    drop_table :elt_cycle_summaries
  end
end
