class CreateClassroomFolders < ActiveRecord::Migration
  def self.up
    create_table :classroom_folders do |t|
      t.integer :classroom_id,   :null => false
      t.integer :folder_id,   :null => false
      t.integer :position,   :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :classroom_folders
  end
end
