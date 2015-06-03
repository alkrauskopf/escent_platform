class AddEarnedPointsToQuestionLog < ActiveRecord::Migration
  def self.up

  remove_column :ifa_question_logs, :points
  add_column    :ifa_question_logs, :earned_points, :decimal, :precision=>3, :scale=>2
  
  end

  def self.down

  add_column  :ifa_question_logs, :points, :integer
  remove_column :ifa_question_logs,  :earned_points
  
  end
end
