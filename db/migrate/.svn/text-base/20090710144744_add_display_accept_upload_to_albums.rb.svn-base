class AddDisplayAcceptUploadToAlbums < ActiveRecord::Migration
  def self.up
    add_column :content_albums, :display, :boolean, :default => false
    add_column :content_albums, :accept_upload, :boolean, :default => false
  end

  def self.down
    remove_column :content_albums, :accept_upload
    remove_column :content_albums, :display
  end
end
