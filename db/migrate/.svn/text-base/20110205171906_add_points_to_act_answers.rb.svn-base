class AddPointsToActAnswers < ActiveRecord::Migration
  def self.up
    add_column :act_answers, :points, :decimal, :precision=>3, :scale => 2
  end

  def self.down
    remove_column :act_answers, :points
  end
end
