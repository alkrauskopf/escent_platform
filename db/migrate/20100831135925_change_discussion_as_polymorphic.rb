class ChangeDiscussionAsPolymorphic < ActiveRecord::Migration
  def self.up
    add_column :discussions, :discussionable_id, :integer
    add_column :discussions, :discussionable_type, :string
    remove_column :discussions, :topic_id    
  end

  def self.down
    remove_column :discussions, :discussionable_id
    remove_column :discussions, :discussionable_type
    add_column :discussions, :topic_id, :integer    
  end
end
