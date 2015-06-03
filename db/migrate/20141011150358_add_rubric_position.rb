class AddRubricPosition < ActiveRecord::Migration
  def self.up

   remove_index :elt_case_indicators, [:elt_rubric_id]
   rename_column  :elt_case_indicators, :elt_rubric_id, :rubric_id
   add_index :elt_case_indicators, [:rubric_id]
   add_column  :rubrics, :position, :integer
   add_column  :elt_case_indicators, :note, :text, :limit => 1024
  end

  def self.down
   remove_column  :elt_case_indicators, :note
   remove_column  :rubrics, :position
   remove_index :elt_case_indicators, [:rubric_id]
   rename_column  :elt_case_indicators, :rubric_id, :elt_rubric_id
   add_index :elt_case_indicators, [:elt_rubric_id]

  end
end
