class AddEvidenceIfaMilestone < ActiveRecord::Migration
  def up
    add_column :ifa_plan_milestones, :evidence, :text
  end

  def down
    remove_column :ifa_plan_milestones, :evidence
  end
end
