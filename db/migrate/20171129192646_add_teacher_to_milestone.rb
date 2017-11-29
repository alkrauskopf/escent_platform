class AddTeacherToMilestone < ActiveRecord::Migration
  def change
    add_column :ifa_plan_milestones, :teacher_id, :integer, :default => nil
  end
end
