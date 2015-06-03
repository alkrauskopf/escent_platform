class AddFolderIndices < ActiveRecord::Migration
  def self.up
    drop_table :content_folders

    add_index :topic_contents, [:folder_id, :topic_id], :name => "folder_for_topic"
    add_index :topic_contents, [:topic_id, :folder_id], :name => "topic_for_folder"
    add_index :topic_contents, [:topic_id, :content_id], :name => "topic_for_content"
    add_index :topic_contents, [:folder_id, :content_id], :name => "folder_for_content"
  end

  def self.down
    remove_index :topic_contents, [:folder_id, :topic_id]
    remove_index :topic_contents, [:topic_id, :folder_id]
    remove_index :topic_contents, [:topic_id, :content_id]
    remove_index :topic_contents, [:folder_id, :content_id]

    create_table :content_folders do |t|
      t.integer :content_id,   :null => false
      t.integer :folder_id,   :null => false
      t.integer :position,   :default => 0

      t.timestamps
    end
  end
end
