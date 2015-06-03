class CreateIstaActivities < ActiveRecord::Migration
  def self.up
    create_table :ista_activities do |t|
      t.integer :ista_group_id
      t.integer :type
      t.string :type_name
      t.string :abbrev
      t.string :name
      t.string :background

      t.timestamps
    end
    add_index :ista_activities, :ista_group_id
  end

  def self.down
    drop_table :ista_activities
  end
end
