class CreateContentContentAlbumJoinTable < ActiveRecord::Migration
  def self.up
    create_table :contents_content_albums, :id => false, :force => true do |t|
      t.integer :content_id, :content_album_id
    end
    remove_column :contents, :content_album_id
  end

  def self.down
    drop_table :contents_content_albums
    add_column :contents, :content_album_id, :integer
  end
end
