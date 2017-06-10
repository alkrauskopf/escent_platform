class QuestionTreeStructure < ActiveRecord::Migration
  def up
    add_column :act_questions, :parent_id, :integer
    add_index :act_questions, [:parent_id]
  end

  def down
    remove_column :act_questions, :parent_id
  end
end
