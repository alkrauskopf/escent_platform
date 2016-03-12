class AddIfaQuestionPerformancesIndexes < ActiveRecord::Migration
  def self.up
    add_index :ifa_question_performances, [:act_question_id, :act_score_range_id], :name => 'question_range'
  end

  def self.down
  end
end
