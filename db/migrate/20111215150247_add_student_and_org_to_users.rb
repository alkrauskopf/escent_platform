class AddStudentAndOrgToUsers < ActiveRecord::Migration
  def self.up

   add_column :users, :is_student, :boolean
   add_column :users, :organization_id, :integer
   execute "UPDATE users SET is_student = 0"
   execute "UPDATE users SET organization_id = home_org_id"
   add_index :users, :is_student
   add_index :users, :organization_id
  
  end

  def self.down
   remove_column :users, :is_student, :boolean
   remove_column :users, :organization_id, :integer

  end
end
