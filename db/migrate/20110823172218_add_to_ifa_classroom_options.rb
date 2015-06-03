class AddToIfaClassroomOptions < ActiveRecord::Migration
  def self.up


   remove_column :ifa_classroom_options, :is_ifa_enabled
   add_column :ifa_classroom_options, :act_subject_id, :integer
   add_column :ifa_classroom_options, :act_master_id, :integer
   add_column :ifa_classroom_options, :is_calibrated, :boolean
   add_column :ifa_classroom_options, :is_user_filterd, :boolean
   add_column :ifa_classroom_options, :max_score_filter, :integer
   add_column :ifa_classroom_options, :days_til_repeat, :integer
   
  end

  def self.down
    
   add_column :ifa_classroom_options, :is_ifa_enabled, :boolean
   remove_column :ifa_classroom_options, :act_subject_id
   remove_column :ifa_classroom_options, :act_master_id
   remove_column :ifa_classroom_options, :is_calibrated
   remove_column :ifa_classroom_options, :is_user_filtered
   remove_column :ifa_classroom_options, :max_score_filter
   remove_column :ifa_classroom_options, :days_til_repeat
   
  end
end
