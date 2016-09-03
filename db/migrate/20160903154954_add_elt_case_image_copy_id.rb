class AddEltCaseImageCopyId < ActiveRecord::Migration
  def up
    add_column :elt_case_evidences, :orig_case_id, :integer, :null => false
    execute "UPDATE elt_case_evidences SET orig_case_id = elt_case_id"
  end

  def down
    remove_column :elt_case_evidences, :orig_case_id
  end
end
