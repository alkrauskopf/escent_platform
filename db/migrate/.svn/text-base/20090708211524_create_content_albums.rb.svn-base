class CreateContentAlbums < ActiveRecord::Migration
  def self.up
    create_table :content_albums do |t|
      t.string :name
      t.string :description, :limit => 8000
      t.integer :organization_id
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end

  def self.down
    drop_table :content_albums
  end
end
