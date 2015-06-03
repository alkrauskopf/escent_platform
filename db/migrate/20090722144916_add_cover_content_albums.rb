class AddCoverContentAlbums < ActiveRecord::Migration
  def self.up
    add_column :content_albums , :cover , :string , :default => ""
  end

  def self.down
    remove_column :content_albums , :cover
  end
end
