class CreateTlActivityTypeTasks < ActiveRecord::Migration
  def self.up
    create_table :tl_activity_type_tasks do |t|
      t.integer :tl_activity_type_id
      t.string :name
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :tl_activity_type_tasks
  end
end
