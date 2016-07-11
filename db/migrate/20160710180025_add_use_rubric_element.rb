class AddUseRubricElement < ActiveRecord::Migration
  def up
    add_column :elt_elements, :use_rubric, :boolean, :default => false
  end

  def down
    remove_column :elt_elements, :use_rubric
  end
end
