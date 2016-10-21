class AddIsHiddenFolders < ActiveRecord::Migration
  def up
    add_column :folder_positions, :is_hidden, :boolean, :default => false
    execute "UPDATE folder_positions SET is_hidden = 0"
  end

  def down
    remove_column :folder_positions, :is_hidden
  end
end
