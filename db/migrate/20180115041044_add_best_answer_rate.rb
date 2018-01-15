class AddBestAnswerRate < ActiveRecord::Migration
  def up
    add_column :act_assessments, :best_answer_rate, :integer, :default=>18000
    change_column :act_assessments, :shortest_duration, :integer, :default=>18000
    change_column :act_assessments, :best_time_per_point, :integer, :default=>18000
  end

  def down
    remove_column :act_assessments, :best_answer_rate, :integer, :default=>18000
    change_column :act_assessments, :shortest_duration, :integer, :default=>0
    change_column :act_assessments, :best_time_per_point, :integer, :default=>0
  end
end
