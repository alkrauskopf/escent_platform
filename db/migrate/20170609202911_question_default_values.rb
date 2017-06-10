class QuestionDefaultValues < ActiveRecord::Migration
  def up
    change_column :act_questions, :comment, :string, :default => ''
    change_column :act_questions, :question_type, :string, :default => 'MC'
    change_column :act_questions, :status, :string, :default => ''
    change_column :act_questions, :is_calibrated, :boolean, :default => false
    change_column :act_questions, :is_active, :boolean, :default => false
    change_column :act_questions, :is_enlarged, :boolean, :default => false
  end

  def down
    change_column :act_questions, :comment, :string
    change_column :act_questions, :question_type, :string
    change_column :act_questions, :status, :string
    change_column :act_questions, :is_calibrated, :boolean
    change_column :act_questions, :is_active, :boolean
    change_column :act_questions, :is_enlarged, :boolean
  end
end
