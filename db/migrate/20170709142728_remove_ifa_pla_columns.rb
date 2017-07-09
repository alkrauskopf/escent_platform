class RemoveIfaPlaColumns < ActiveRecord::Migration
  def up
    remove_column :ifa_plans, :current_mastery
    remove_column :ifa_plans, :goal_date
    remove_column :ifa_plans, :is_accepted
    remove_column :ifa_plans, :accepted_by
    remove_column :ifa_plans, :is_final
    remove_column :ifa_plans, :accepted_date
  end

  def down
    add_column :ifa_plans, :current_mastery, :string
    add_column :ifa_plans, :goal_date, :date
    add_column :ifa_plans, :is_accepted, :boolean
    add_column :ifa_plans, :accepted_by, :string
    add_column :ifa_plans, :is_final, :boolean
    add_column :ifa_plans, :accepted_date, :date
  end
end
