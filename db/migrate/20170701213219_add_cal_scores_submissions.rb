class AddCalScoresSubmissions < ActiveRecord::Migration
  def up
    add_column :act_submissions, :cal_points, :decimal, :precision =>6, :scale => 2, :default => 0.0
    add_column :act_submissions, :cal_choices, :integer, :default => 0
  end

  def down
    remove_column :act_submissions, :cal_points
    remove_column :act_submissions, :cal_choices
  end
end
