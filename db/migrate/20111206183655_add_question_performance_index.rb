class AddQuestionPerformanceIndex < ActiveRecord::Migration
  def self.up

    add_index :ifa_question_performances, :act_score_range_id

  end

  def self.down

    remove_index :ifa_question_performances, :act_score_range_id

  end
end
