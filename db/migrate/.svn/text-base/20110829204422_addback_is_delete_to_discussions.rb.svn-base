class AddbackIsDeleteToDiscussions < ActiveRecord::Migration
  def self.up
    add_column :discussions , :is_delete, :boolean , :default => false
    add_column :discussions , :is_suspended, :boolean , :default => false
  end

  def self.down
    remove_column :discussions , :is_delete
    remove_column :discussions , :is_suspended
  end
end
