class AddRubricCaseNote < ActiveRecord::Migration
  def up
    add_column :elt_case_notes, :rubric_id, :integer
    add_index :elt_case_notes, ['rubric_id', 'elt_case_id'], :name => 'rubric_case'
    add_index :elt_case_notes, ['rubric_id', 'elt_element_id'], :name => 'rubric_element'
  end

  def down
    remove_column :elt_case_notes, :rubric_id
  end
end
