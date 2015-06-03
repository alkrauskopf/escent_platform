class AddUserIdToClassrooms < ActiveRecord::Migration
  def self.up
    add_column :classrooms, :user_id, :integer
  end

  def self.down
    remove_column :classrooms, :user_id
  end
end
