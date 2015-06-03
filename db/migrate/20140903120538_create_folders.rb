class CreateFolders < ActiveRecord::Migration
  def self.up
    create_table :folders do |t|
      t.integer :parent_id
      t.integer :organization_id,  :null => false
      t.integer :folderable_id
      t.string :folderable_type
      t.string :name
      t.string :abbrev,  :limit => 8
      t.integer :position
      t.text :description,  :limit => 8000

      t.timestamps
    end
  end

  def self.down
    drop_table :folders
  end
end
