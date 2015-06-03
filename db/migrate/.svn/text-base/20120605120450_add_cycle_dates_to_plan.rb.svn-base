class AddCycleDatesToPlan < ActiveRecord::Migration
  def self.up

    add_column :user_dle_plans, :cycle_start_date, :date
    add_column :user_dle_plans, :cycle_finish_date, :date
    
    add_index :user_dle_plans, :cycle_start_date
    add_index :user_dle_plans, :cycle_finish_date

  end

  def self.down
    remove_column :user_dle_plans, :cycle_start_date
    remove_column :user_dle_plans, :cycle_finish_date

  end
end
