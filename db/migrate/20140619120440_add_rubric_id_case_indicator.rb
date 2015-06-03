class AddRubricIdCaseIndicator < ActiveRecord::Migration
  def self.up

   rename_column  :elt_case_indicators, :rating, :elt_rubric_id
   add_index :elt_case_indicators, [:elt_rubric_id]

  end

  def self.down

   remove_index :elt_case_indicators, [:elt_rubric_id]
   rename_column  :elt_case_indicators, :elt_rubric_id, :rating

  end
end
