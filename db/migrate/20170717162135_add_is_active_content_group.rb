class AddIsActiveContentGroup < ActiveRecord::Migration
  def up
    add_column :content_object_type_groups, :is_active, :boolean, :default => true
  end

  def down
    remove_column :content_object_type_groups, :is_active
  end
end
