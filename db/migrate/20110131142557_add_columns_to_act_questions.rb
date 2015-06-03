class AddColumnsToActQuestions < ActiveRecord::Migration
  def self.up
    add_column :act_questions, :is_locked, :boolean, :default => false
    add_column :act_choices, :correct, :boolean, :default => false
    add_column :act_questions, :original_question_id, :integer
    add_column :act_questions, :generation, :integer, :default => 0
    execute "UPDATE act_questions SET original_question_id = id"
    execute "UPDATE act_questions SET generation = 0"  
  end

  def self.down
    remove_column :act_questions, :is_locked
    remove_column :act_choices, :correct
    remove_column :act_questions, :original_question_id
    remove_column :act_questions, :generation
  
  end
end
