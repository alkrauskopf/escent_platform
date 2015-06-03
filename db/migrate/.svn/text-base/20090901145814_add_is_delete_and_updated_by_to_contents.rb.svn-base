class AddIsDeleteAndUpdatedByToContents < ActiveRecord::Migration
  def self.up
    add_column :contents, :is_delete, :boolean , :default => false
    add_column :contents, :updated_by, :integer
  end

  def self.down
    remove_column :contents, :updated_by
    remove_column :contents, :is_delete
  end
end
