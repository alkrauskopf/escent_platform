class AddContentEltCaseEvidence < ActiveRecord::Migration
  def up
    add_column :elt_case_evidences, :content_id, :integer
    add_index :elt_case_evidences, :content_id
  end

  def down
    remove_column :elt_case_evidences, :content_id
  end
end
