class CreateTopicsAndDiscussionsTables < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.integer  :organization_id,                              :null => false
      t.integer  :user_id,                                      :null => false
      t.string   :title
      t.string   :description, :limit => 8000
      t.boolean  :searchable,                         :default => true, :null => false
      t.datetime :publish_starts_at
      t.datetime :publish_ends_at
      t.datetime :last_posted_at
      t.timestamps
    end
    add_index :topics, [:organization_id]
    
    create_table :discussions do |t|
      t.integer  :parent_id
      t.integer  :organization_id,                      :null => false
      t.integer  :user_id,                              :null => false
      t.integer  :topic_id
      t.string   :comment,        :limit => 8000
      t.datetime :last_posted_at
      t.timestamps
    end
    add_index :discussions, [:organization_id]
    add_index :discussions, [:topic_id]
    
    create_table :topic_contents, :force => true do |t|
      t.integer  :topic_id, :null => false
      t.integer  :content_id, :null => false
      t.integer  :position
      t.timestamps
    end
    
    add_index :topic_contents, [:topic_id]
    
    create_table :outreach_priorities_topics, :id => false, :force => true do |t|
      t.integer  :outreach_priority_id, :default => 0, :null => false
      t.integer  :topic_id,             :default => 0, :null => false
      t.datetime :created_at
    end
  
    add_index :outreach_priorities_topics, [:topic_id, :outreach_priority_id], :name => "index_topic_id_and_outreach_priority_id", :unique => true
    add_index :outreach_priorities_topics, [:outreach_priority_id, :topic_id], :name => "index_outreach_priority_id_and_topic_id", :unique => true
 
  end

  def self.down
    drop_table :topics
    drop_table :discussions
    drop_table :topic_contents
    drop_table :outreach_priorities_topics
  end
end
