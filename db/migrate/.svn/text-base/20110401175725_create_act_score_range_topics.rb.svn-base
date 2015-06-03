class CreateActScoreRangeTopics < ActiveRecord::Migration
  def self.up
    create_table :act_score_range_topics do |t|
      t.integer :topic_id
      t.integer :act_score_range_id

      t.timestamps
    end
  end

  def self.down
    drop_table :act_score_range_topics
  end
end
