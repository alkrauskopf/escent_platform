class AddStandardRubicId < ActiveRecord::Migration
  def up
    add_column :elt_standards, :rubric_id, :integer
    add_index :elt_standards, :rubric_id
  end

  def down
    remove_column :elt_standards, :rubric_id
  end
end
