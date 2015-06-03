class RemoveScoreRangeFromQuestionLog < ActiveRecord::Migration
  def self.up

  remove_column :ifa_question_logs, :act_score_range_id  
  
  end

  def self.down

  add_column :ifa_question_logs, :act_score_range_id, :integer
  
  end
end
