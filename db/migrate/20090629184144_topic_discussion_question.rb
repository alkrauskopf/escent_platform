class TopicDiscussionQuestion < ActiveRecord::Migration
  def self.up
    add_column :topics, :discussion_question, :string, :limit => 1000    
  end

  def self.down
    remove_column :topics, :discussion_question
  end
end
