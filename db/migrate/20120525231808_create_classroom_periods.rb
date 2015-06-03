class CreateClassroomPeriods < ActiveRecord::Migration
  def self.up
    create_table :classroom_periods do |t|
      t.integer :classroom_id
      t.string :name, :limit => 32
      t.integer :week_duration

      t.timestamps
    end

    add_index :classroom_periods, :classroom_id
   end

  def self.down
    drop_table :classroom_periods
  end
end
