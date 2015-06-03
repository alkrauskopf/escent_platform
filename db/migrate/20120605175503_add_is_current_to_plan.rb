class AddIsCurrentToPlan < ActiveRecord::Migration
  def self.up
    add_column :user_dle_plans, :is_current, :boolean, :default=> true
  end

  def self.down
    remove_column :user_dle_plans, :is_current
  end
end
