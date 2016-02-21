class Remove2IfaQuestionLogIndexes < ActiveRecord::Migration
  def self.up
    remove_index :ifa_question_logs, [:grade_level]
    remove_index :ifa_question_logs, [:csap]
  end

  def self.down
  end
end
