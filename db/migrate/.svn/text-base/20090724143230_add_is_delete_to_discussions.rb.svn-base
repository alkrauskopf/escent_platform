class AddIsDeleteToDiscussions < ActiveRecord::Migration
  def self.up
    add_column :discussions , :is_delete, :boolean , :default => false
  end

  def self.down
    remove_column :discussions , :is_delete
  end
end
