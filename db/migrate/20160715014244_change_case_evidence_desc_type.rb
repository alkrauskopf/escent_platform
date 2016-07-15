class ChangeCaseEvidenceDescType < ActiveRecord::Migration
  def up
    change_column :elt_case_evidences, :description, :text
  end

  def down
    change_column :elt_case_evidences, :description, :string
  end
end
