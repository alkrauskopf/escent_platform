class CreateContentFolders < ActiveRecord::Migration
  def self.up
    create_table :content_folders do |t|
      t.integer :content_id,   :null => false
      t.integer :folder_id,   :null => false
      t.integer :position,   :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :content_folders
  end
end
