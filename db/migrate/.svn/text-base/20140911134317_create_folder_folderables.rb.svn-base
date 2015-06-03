class CreateFolderFolderables < ActiveRecord::Migration
  def self.up
    create_table :folder_folderables do |t|
      t.integer :folder_id
      t.integer :folderable_id
      t.string :folderable_type
      t.integer :position

      t.timestamps
    end
    add_index :folder_folderables, [:folder_id], :name => "folder"
    add_index :folder_folderables, [:folderable_id], :name => "folderable"
    add_index :folder_folderables, [:folderable_type, :folderable_id], :name => "folderable_type"
  end

  def self.down
    drop_table :folder_folderables
  end
end
