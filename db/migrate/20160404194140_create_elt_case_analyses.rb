class CreateEltCaseAnalyses < ActiveRecord::Migration
  def self.up
   create_table :elt_case_analyses do |t|
      t.integer :elt_case_id
      t.integer :elt_element_id
      t.integer :elt_std_indicator_id
      t.integer :provider_id
      t.integer :rubric_id
      t.text :strengths
      t.text :considerations

      t.timestamps
    end
    add_index :elt_case_analyses, [:elt_case_id]
    add_index :elt_case_analyses, [:rubric_id]
    add_index :elt_case_analyses, [:elt_std_indicator_id]
    add_index :elt_case_analyses, [:elt_element_id]
    add_index :elt_case_analyses, [:provider_id]
  end

  def self.down
    drop_table :elt_case_analyses
  end
end
