class ChangeIsDeleteToDeleteBy < ActiveRecord::Migration
  def self.up
    remove_column :discussions , :is_delete
    add_column :discussions, :deleted_by, :integer
  end

  def self.down
    remove_column :discussions, :deleted_by
    add_column :discussions , :is_delete, :boolean , :default => false
  end
end
