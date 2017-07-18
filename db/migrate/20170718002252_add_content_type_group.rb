class AddContentTypeGroup < ActiveRecord::Migration
  def up
    add_column :contents, :content_object_type_group_id, :integer
    add_index :contents, [:content_object_type_group_id]
  end

  def down
    remove_column :contents, :content_object_type_group_id
  end
end
