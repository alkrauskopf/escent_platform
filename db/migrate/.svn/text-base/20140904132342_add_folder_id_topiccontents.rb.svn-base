class AddFolderIdTopiccontents < ActiveRecord::Migration
  def self.up

    add_column  :topic_contents, :folder_id,  :integer

    add_index   :topic_contents, :folder_id 

  end

  def self.down

    remove_column  :topic_contents, :folder_id

  end
end
