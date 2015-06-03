class AddAttachedFileToUserDlePlan < ActiveRecord::Migration
  def self.up
 
    add_column :user_dle_plans, :user_dle_plan_content_type, :string
    add_column :user_dle_plans, :user_dle_plan_file_name, :string 
    add_column :user_dle_plans, :user_dle_plan_file_size, :integer
  end

  def self.down
    remove_column :user_dle_plans, :user_dle_plan_content_type
    remove_column :user_dle_plans, :user_dle_plan_file_name
    remove_column :user_dle_plans, :user_dle_plan_file_size

  end
end
