class AddContentAlbumToUser < ActiveRecord::Migration
  def self.up
    add_column :content_albums, :user_id, :integer    
  end

  def self.down
    remove_column :content_albums, :user_id
  end
end
