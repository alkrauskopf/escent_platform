class CreateEltCaseEvidences < ActiveRecord::Migration
  def change
    create_table :elt_case_evidences do |t|
      t.integer :elt_case_id
      t.string :description
      t.string :file_name
      t.string :content_type
      t.integer :file_size

      t.timestamps
    end
    add_index :elt_case_evidences, [:elt_case_id]
  end
end
