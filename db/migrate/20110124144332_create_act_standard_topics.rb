class CreateActStandardTopics < ActiveRecord::Migration
  def self.up
    create_table :act_standard_topics do |t|
      t.integer :topic_id
      t.integer :act_standard_id
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :act_standard_topics
  end
end
