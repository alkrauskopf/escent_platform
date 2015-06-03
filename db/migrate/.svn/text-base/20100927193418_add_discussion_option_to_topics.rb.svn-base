class AddDiscussionOptionToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :is_open, :boolean, :default => true
    add_column :topics, :should_notify, :boolean, :default => false
    execute "UPDATE topics SET is_open = 1"
    execute "UPDATE topics SET should_notify = 0"
    
  end

  def self.down
    remove_column :topics, :is_open
    remove_column :topics, :should_notify
  end
end
