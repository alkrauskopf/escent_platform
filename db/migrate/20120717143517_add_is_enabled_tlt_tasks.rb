class AddIsEnabledTltTasks < ActiveRecord::Migration
  def self.up
    add_column :tl_activity_type_tasks, :is_enabled, :boolean
    execute "UPDATE tl_activity_type_tasks SET is_enabled = 1"  
  end

  def self.down
    remove_column :tl_activity_type_tasks, :is_enabled
  end
end
