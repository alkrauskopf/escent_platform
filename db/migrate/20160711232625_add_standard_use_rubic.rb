class AddStandardUseRubic < ActiveRecord::Migration
  def up
    add_column :elt_standards, :use_rubric, :boolean, :default => false
  end

  def down
    remove_column :elt_standards, :use_rubric
  end
end
