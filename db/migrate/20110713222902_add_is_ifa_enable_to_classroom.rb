class AddIsIfaEnableToClassroom < ActiveRecord::Migration
  def self.up
   add_column :classrooms, :is_ifa_enabled, :boolean
  end

  def self.down
   remove_column :classrooms, :is_ifa_enabled
  end
end
