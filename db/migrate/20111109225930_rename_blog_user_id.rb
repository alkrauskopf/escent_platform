class RenameBlogUserId < ActiveRecord::Migration
  def self.up

  rename_column :blogs, :user_id, :creator_id

  end

  def self.down
    
  rename_column :blogs, :creator_id, :user_id

  end
end
