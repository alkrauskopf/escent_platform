class AddFolderPositionPos < ActiveRecord::Migration
  def up
    add_column :folder_positions, :pos, :integer, :default => '1'
    execute "UPDATE folder_positions SET pos = position"
  end

  def down
    remove_column :folder_positions, :pos
  end
end
