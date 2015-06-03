class RenameTopicIdInHomeworks < ActiveRecord::Migration
  def self.up
    rename_column :homeworks, :topic_id, :classroom_id
    add_column :homeworks, :topic_title, :string
  end

  def self.down
        rename_column :homeworks, :classroom_id, :topic_id
        remove_column :homeworks, :topic_title
  end
end
