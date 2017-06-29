class DecimalTotPointScaleIncrease < ActiveRecord::Migration
  def up
    change_column :act_submissions, :tot_points, :decimal, :precision =>6, :scale => 2, :default => 0.0
    change_column :act_answers, :points, :decimal, :precision => 5, :scale => 2, :default => 0.0
  end

  def down
    change_column :act_submissions, :tot_points, :decimal, :precision =>3, :scale => 2, :default => 0.0
    change_column :act_answers, :points, :decimal, :precision => 3, :scale => 2, :default => 0.0
  end
end
