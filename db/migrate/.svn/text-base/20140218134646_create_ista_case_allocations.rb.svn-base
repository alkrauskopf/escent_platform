class CreateIstaCaseAllocations < ActiveRecord::Migration
  def self.up
    create_table :ista_case_allocations do |t|
      t.integer :activity_id
      t.string :activity_type
      t.integer :ista_case_id,   :null => false
      t.integer :ista_step_id,   :null => false
      t.integer :minsweek,      :default => 0
      t.integer :hrsyear,      :default => 0
      t.string :comment,   :limit => 250

      t.timestamps
    end
    add_index :ista_case_allocations, [:ista_case_id]
    add_index :ista_case_allocations, [:ista_step_id]
  end

  def self.down
    drop_table :ista_case_allocations
  end
end
