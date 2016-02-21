class AddActReadingScoreRangeIndexes < ActiveRecord::Migration
  def self.up
    add_index :act_rel_reading_act_score_ranges, [:act_master_id, :act_score_range_id, ], :name => 'standard_range'
  end

  def self.down
  end
end
