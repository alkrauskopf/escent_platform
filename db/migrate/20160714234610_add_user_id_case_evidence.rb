class AddUserIdCaseEvidence < ActiveRecord::Migration
  def up
    add_column :elt_case_evidences, :user_id, :integer
    add_index :elt_case_evidences, :user_id
  end

  def down
    remove_column :elt_case_evidences, :user_id
  end
end
