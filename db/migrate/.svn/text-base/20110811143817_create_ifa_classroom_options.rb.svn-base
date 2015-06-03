class CreateIfaClassroomOptions < ActiveRecord::Migration
  def self.up
    create_table :ifa_classroom_options do |t|
      t.integer :classroom_id
      t.boolean :is_ifa_enabled
      t.boolean :is_ifa_notify
      t.boolean :is_ifa_auto_finalize

      t.timestamps
    end
  end

  def self.down
    drop_table :ifa_classroom_options
  end
end
