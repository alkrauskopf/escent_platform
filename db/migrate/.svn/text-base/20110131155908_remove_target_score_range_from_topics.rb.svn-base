class RemoveTargetScoreRangeFromTopics < ActiveRecord::Migration
  def self.up
    remove_column :topics, :target_score_range
  end

  def self.down
    add_column :topics, :target_score_range,:string
  end
end
