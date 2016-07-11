class AddRubricElement < ActiveRecord::Migration
  def up
    add_column :elt_elements, :rubric_id, :integer
    add_index :elt_elements, :rubric_id
  end

  def down
    drop_column :elt_elements, :rubric_id
  end
end
