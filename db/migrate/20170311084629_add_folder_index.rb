class AddFolderIndex < ActiveRecord::Migration
  def up
    add_index :folders, [:name]
  end

  def down
    remove_index :folders, [:name]
  end
end
