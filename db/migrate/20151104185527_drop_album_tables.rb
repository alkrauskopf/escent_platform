class DropAlbumTables < ActiveRecord::Migration
  def self.up
    drop_table :content_albums
    drop_table :content_albums_contents
  end

  def self.down
  end
end
