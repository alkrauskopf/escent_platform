class RemoveUserIdFromAlbums < ActiveRecord::Migration
  def self.up
    remove_column :content_albums, :user_id    
  end

  def self.down
    add_column :content_albums, :user_id, :integer    
  end
end
