class AddPeriodNameTltSession < ActiveRecord::Migration
  def self.up
    add_column :tlt_sessions, :class_period_name, :text
    add_column :tlt_sessions, :classroom_name, :text
  end

  def self.down
     remove_column :tlt_sessions, :class_period_name     
     remove_column :tlt_sessions, :classroom_name
  end
end
