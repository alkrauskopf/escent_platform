class RenameIsLeader < ActiveRecord::Migration
  def self.up
 
    rename_column :classroom_period_users, :is_leader, :is_teacher
  end

  def self.down
 
    rename_column :classroom_period_users, :is_teacher, :is_leader

  end
end
