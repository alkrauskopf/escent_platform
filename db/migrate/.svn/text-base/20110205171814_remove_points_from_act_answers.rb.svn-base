class RemovePointsFromActAnswers < ActiveRecord::Migration
  def self.up
    remove_column :act_answers, :points
  end

  def self.down
    add_column :act_answers, :points, :decimal, :precision=>3, :scale => 2
  end
end
