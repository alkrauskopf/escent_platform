class AddActToTopic < ActiveRecord::Migration
  def self.up
    add_column :topics, :act_score_range_id, :integer
    add_column :topics, :act_standard_id, :integer
  end

  def self.down
    remove_column :topics, :act_standard_id
    remove_column :topics, :act_score_range_id
  end
end
