class AddFilterOptionsToIfaUser < ActiveRecord::Migration
  def self.up
 
   add_column :ifa_user_options, :is_org_filtered, :boolean
   add_column :ifa_user_options, :is_classroom_filtered, :boolean  
   add_column :ifa_user_options, :is_student_filtered, :boolean
   add_column :ifa_user_options, :is_colleague_filtered, :boolean
   add_column :ifa_user_options, :beginning_period, :date  
   execute "UPDATE ifa_user_options SET is_org_filtered = 0"
   execute "UPDATE ifa_user_options SET is_classroom_filtered = 0"  
   execute "UPDATE ifa_user_options SET is_student_filtered = 0"
   execute "UPDATE ifa_user_options SET is_colleague_filtered = 0"
  end

  def self.down

   remove_column :ifa_user_options, :is_org_filtered
   remove_column :ifa_user_options, :is_classroom_filtered
   remove_column :ifa_user_options, :is_student_filtered
   remove_column :ifa_user_options, :is_colleague_filtered
   remove_column :ifa_user_options, :beginning_period
  
  end
end
