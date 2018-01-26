class AddQuestionAllottedTime < ActiveRecord::Migration
  def up
    add_column :act_questions, :allotted_time, :integer, :default=>0
    add_column :act_subjects, :question_time, :integer, :default=>0
  end

  def down
    remove_column :act_questions, :allotted_time
    remove_column :act_subjects, :question_time
  end
end
