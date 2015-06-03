class RenameAttachcolsInPlan < ActiveRecord::Migration
  def self.up
     remove_column :user_dle_plans, :attach_content_type    
     rename_column :user_dle_plans, :user_dle_plan_content_type, :attach_content_type
     rename_column :user_dle_plans, :user_dle_plan_file_name, :attach_file_name
     rename_column :user_dle_plans, :user_dle_plan_file_size, :attach_file_size
  end

  def self.down
     add_column :user_dle_plans, :attach_content_type, :string
     rename_column :user_dle_plans, :attach_content_type, :user_dle_plan_content_type
     rename_column :user_dle_plans, :attach_file_name, :user_dle_plan_file_name
     rename_column :user_dle_plans, :attach_file_size, :user_dle_plan_file_size
  end
end
