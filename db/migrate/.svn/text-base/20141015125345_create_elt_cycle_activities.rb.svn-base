class CreateEltCycleActivities < ActiveRecord::Migration
  def self.up
    create_table :elt_cycle_activities do |t|
      t.integer :elt_cycle_id
      t.integer :elt_type_id

      t.timestamps
    end
  add_index :elt_cycle_activities, [:elt_cycle_id, :elt_type_id], :name => "cycle_activity"
  add_index :elt_cycle_activities, [:elt_type_id, :elt_cycle_id], :name => "activity_cycle"
  end

  def self.down
    drop_table :elt_cycle_activities
  end
end
