class AddScoreRangeColorActive < ActiveRecord::Migration
  def up
    add_column  :act_score_ranges, :score_background, :string, :limit=>7, :default=>'#F8F8F8'
    add_column  :act_score_ranges, :score_font, :string, :limit=>7, :default=>'#000000'
    add_column :act_score_ranges, :is_active, :boolean, :default => false
    execute "UPDATE act_score_ranges SET is_active = 1 WHERE upper_score > 0"
  end

  def down
    remove_column  :act_score_ranges, :score_background
    remove_column  :act_score_ranges, :score_font
    remove_column :act_score_ranges, :is_active
  end
end
