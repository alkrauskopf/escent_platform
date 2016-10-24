class AddSatScoreMapId < ActiveRecord::Migration
  def up
    add_column :act_score_ranges, :act_sat_map_id, :integer
    add_index :act_score_ranges, :act_sat_map_id
  end

  def down
    remove_column :act_score_ranges, :act_sat_map_id
  end
end
