class AddMonthWindowForAnalysis < ActiveRecord::Migration
  def self.up
     add_column :act_app_options, :months_for_questions, :integer
     execute "UPDATE act_app_options SET months_for_questions = 3" 
  end

  def self.down
    remove_column :act_app_options, :months_for_questions
 
  end
end
