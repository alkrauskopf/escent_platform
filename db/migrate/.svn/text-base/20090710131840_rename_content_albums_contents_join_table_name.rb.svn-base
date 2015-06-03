class RenameContentAlbumsContentsJoinTableName < ActiveRecord::Migration
  def self.up
    rename_table :contents_content_albums, :content_albums_contents
  end

  def self.down
    rename_table :content_albums_contents, :contents_content_albums
  end
end
