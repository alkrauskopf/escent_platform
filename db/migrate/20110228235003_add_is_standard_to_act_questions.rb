class AddIsStandardToActQuestions < ActiveRecord::Migration
  def self.up
    add_column :act_questions, :is_standard, :boolean
    execute "UPDATE act_questions SET is_standard = 0"
  
  end

  def self.down
    remove_column :act_questions, :is_standard
  
  end
end
