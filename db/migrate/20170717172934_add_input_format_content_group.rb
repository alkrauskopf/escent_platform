class AddInputFormatContentGroup < ActiveRecord::Migration
  def up
    add_column :content_object_type_groups, :content_format, :string, :default => 'Attachment'
  end

  def down
    remove_column :content_object_type_groups, :content_format
  end
end
