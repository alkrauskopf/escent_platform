class AddCycleDateFromPlan < ActiveRecord::Migration
  def self.up

    remove_column :user_dle_plans, :cycle_finish_date

  end

  def self.down
    add_column :user_dle_plans, :cycle_finish_date, :date
    add_index :user_dle_plans, :cycle_finish_date

  end
end
