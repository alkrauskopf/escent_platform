class AddSequenceActivityTasks < ActiveRecord::Migration
  def self.up

   add_column :tl_activity_type_tasks, :position, :integer

  end

  def self.down

 remove_column :tl_activity_type_tasks, :position

  end
end
