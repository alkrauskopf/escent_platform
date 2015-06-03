class AddClassroomIdToMessages < ActiveRecord::Migration
  def self.up

    add_column :messages, :classroom_id, :integer 
    add_column :messages, :sender_id, :integer 
    
    end

  def self.down

    remove_column :messages, :classroom_id
    remove_column :messages, :sender_id
    
  end
end
