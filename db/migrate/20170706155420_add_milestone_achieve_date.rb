class AddMilestoneAchieveDate < ActiveRecord::Migration
  def up
    add_column :ifa_plan_milestones, :achieve_date, :date
  end

  def down
    remove_column :ifa_plan_milestones, :achieve_date
  end
end
