class AddResearchImpactItlTasks < ActiveRecord::Migration
  def self.up

   add_column :tl_activity_type_tasks, :research, :integer

  end

  def self.down

   remove_column :tl_activity_type_tasks, :research

  end
end
