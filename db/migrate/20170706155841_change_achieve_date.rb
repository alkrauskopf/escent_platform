class ChangeAchieveDate < ActiveRecord::Migration
  def up
    change_column :ifa_plan_milestones, :achieve_date, :datetime, :default=>Time.now
  end

  def down
    change_column :ifa_plan_milestones, :achieve_date, :date
  end
end
