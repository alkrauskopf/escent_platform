class AddIfaNotifyAutoFinalizeToClassroom < ActiveRecord::Migration
  def self.up

   add_column :classrooms, :is_ifa_notify, :boolean
   add_column :classrooms, :is_ifa_auto_finalize, :boolean
   execute "UPDATE classrooms SET is_ifa_notify = 1"
   execute "UPDATE classrooms SET is_ifa_auto_finalize = 0"   
   execute "UPDATE classrooms SET is_ifa_enabled = 0"   
  end

  def self.down
   remove_column :classrooms, :is_ifa_notify
   remove_column :classrooms, :is_ifa_auto_finalize
  
  end
end
