class AddPlanNumToPlan < ActiveRecord::Migration
  def self.up
    add_column :user_dle_plans, :plan, :integer
    add_index :user_dle_plans, [:user_id, :plan]
  end
  def self.down
    remove_column :user_dle_plans, :plan
  end
end
