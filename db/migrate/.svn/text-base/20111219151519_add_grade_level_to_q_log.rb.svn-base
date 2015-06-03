class AddGradeLevelToQLog < ActiveRecord::Migration
  def self.up
   add_column :ifa_question_logs, :grade_level, :integer
   add_column :ifa_question_logs, :csap, :integer

   add_index  :ifa_question_logs, :grade_level
   add_index  :ifa_question_logs, :csap

  end

  def self.down

   remove_column :ifa_question_logs, :grade_level
   remove_column :ifa_question_logs, :csap

  end
end
