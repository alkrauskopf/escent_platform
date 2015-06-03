class RemoveActStandardFromTopic < ActiveRecord::Migration
  def self.up
    remove_column :topics, :act_standard_id
    remove_column :topics, :act_score_range_id 
    add_column :topics, :target_score_range,:string 
    execute "UPDATE topics SET target_score_range =' -na- '"
  end

  def self.down
    add_column :topics, :act_standard_id,:integer
    add_column :topics, :act_score_range_id,:integer
    remove_column :topics, :target_score_range
  end
end
