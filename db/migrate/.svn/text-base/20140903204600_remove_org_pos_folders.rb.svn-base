class RemoveOrgPosFolders < ActiveRecord::Migration
  def self.up

    remove_column  :folders, :organization_id
    remove_column  :folders, :position

    add_index :folders, [:folderable_type, :folderable_id], :name => "folder_type_id"

  end

  def self.down
    add_column  :folderss, :organization_id, :integer
    add_column  :folders, :position, :integer
  end
end
