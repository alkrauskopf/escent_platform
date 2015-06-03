class RenameAttDatePlan < ActiveRecord::Migration
  def self.up
     remove_column :user_dle_plans, :content_object_type_id
     add_column :user_dle_plans, :attach_date, :date 
  end

  def self.down
    remove_column :user_dle_plans, :attach_date
    add_column :user_dle_plans, :content_object_type_id, :integer
  end
end
