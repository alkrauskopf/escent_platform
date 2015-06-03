class CreateTimeAllocations < ActiveRecord::Migration
  def self.up
    create_table :time_allocations do |t|
      t.integer :organization_id
      t.time :start_time_std
      t.time :end_time_std
      t.decimal :weekday_std, :precision => 2, :scale => 1, :default => 5.0
      t.decimal :daysyear_std, :precision => 4, :scale => 1, :default => 180.0
      t.time :start_time_er
      t.time :end_time_er
      t.decimal :daysyear_er, :precision => 4, :scale => 1, :default => 0.0
      t.time :start_time_ls
      t.time :end_time_ls
      t.decimal :daysyear_ls, :precision => 4, :scale => 1, :default => 0.0
      t.decimal :fte_teacher, :precision => 4, :scale => 1, :default => 0.0
      t.decimal :fte_admin, :precision => 4, :scale => 1, :default => 0.0
      t.integer :total_students, :default => 0

      t.timestamps
    end
    add_index :time_allocations, :organization_id
  end

  def self.down
    drop_table :time_allocations
  end
end
