class AddRubricIndexesCaseIndicators < ActiveRecord::Migration
  def self.up
   remove_index :elt_case_indicators, [:rubric_id]
   add_index :elt_case_indicators, [:rubric_id, :elt_indicator_id], :name=>"rubric_indicator"
   add_index :elt_case_indicators, [:rubric_id, :elt_case_id], :name=>"rubric_case"
  end

  def self.down
   remove_index :elt_case_indicators, [:rubric_id, :elt_case_id]
   remove_index :elt_case_indicators, [:rubric_id, :elt_indicator_id]
   add_index :elt_case_indicators, [:rubric_id]
  end
end
