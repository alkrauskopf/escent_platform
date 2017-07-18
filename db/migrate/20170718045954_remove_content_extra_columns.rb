class RemoveContentExtraColumns < ActiveRecord::Migration
  def up
    remove_column :contents, :content_object_type_group_id
    drop_attached_file :contents, :resource
  end

  def down
    change_table :contents do |t|
      t.has_attached_file :resource
    end
    add_column :contents, :content_object_type_group_id, :integer
    add_index :contents, [:content_object_type_group_id]
  end
end
