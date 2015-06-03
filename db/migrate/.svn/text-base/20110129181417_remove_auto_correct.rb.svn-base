class RemoveAutoCorrect < ActiveRecord::Migration
  def self.up
    add_column :act_questions, :question_type, :string
    remove_column :act_questions, :auto_correct
  end

  def self.down
    add_column :act_questions, :auto_correct, :binary
    remove_column :act_questions, :question_type
  end
end
