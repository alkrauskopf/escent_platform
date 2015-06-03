class AddTltIndexes < ActiveRecord::Migration
  def self.up

    add_index :tlt_sessions, :user_id
    add_index :tlt_sessions, :classroom_id
    add_index :tlt_sessions, :tracker_id
    add_index :tl_activity_type_tasks, :tl_activity_type_id
  end

  def self.down

    remove_index :tlt_sessions, :user_id
    remove_index :tlt_sessions, :classroom_id
    remove_index :tlt_sessions, :tracker_id
    remove_index :tl_activity_type_tasks, :tl_activity_type_id
  end
end
