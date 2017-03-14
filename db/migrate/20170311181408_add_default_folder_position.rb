class AddDefaultFolderPosition < ActiveRecord::Migration
  def up
    change_column :folder_folderables, :position, :integer, default: 1
  end

  def down
    change_column :folder_folderables, :position, :integer
  end
end
