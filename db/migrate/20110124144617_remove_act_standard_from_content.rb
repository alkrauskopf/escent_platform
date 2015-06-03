class RemoveActStandardFromContent < ActiveRecord::Migration
  def self.up
    remove_column :contents, :act_standard_id
    remove_column :contents, :act_score_range_id 
    add_column :contents, :target_score_range,:string 
    execute "UPDATE contents SET target_score_range =' -na- '"
  end

  def self.down
    add_column :contents, :act_standard_id,:integer
    add_column :contents, :act_score_range_id,:integer
    remove_column :contents, :target_score_range
  end
end
