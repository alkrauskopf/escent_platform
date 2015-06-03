class AddMsgtextPhoneAndProvider < ActiveRecord::Migration
  def self.up
   add_column :users, :Phone_for_Texting, :string
   add_column :users, :Provider_of_Texting_Service, :string
  end

  def self.down
   remove_column :users, :Phone_for_Texting
   remove_column :users, :Provider_of_Texting_Service
  end
end
