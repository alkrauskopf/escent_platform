class AddContentAlbumToContent < ActiveRecord::Migration
  def self.up
    add_column :contents, :content_album_id, :integer
    add_column :contents, :pending, :boolean, :default => false
    add_column :contents, :content_upload_source_id, :boolean, :default => 1
  end

  def self.down
    remove_column :contents, :content_album_id
    remove_column :contents, :pending
    remove_column :contents, :uploaded_source_id
  end
end
