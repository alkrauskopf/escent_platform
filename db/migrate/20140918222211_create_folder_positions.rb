class CreateFolderPositions < ActiveRecord::Migration
  def self.up
    create_table :folder_positions do |t|
      t.integer :folder_id
      t.integer :scope_id
      t.string :scope_type
      t.integer :position

      t.timestamps
    end
    add_index :folder_positions, [:folder_id], :name => "folder"
    add_index :folder_positions, [:scope_id], :name => "scope"
    add_index :folder_positions, [:scope_type, :scope_id], :name => "scope_type"

  end

  def self.down
    drop_table :folder_positions
  end
end
