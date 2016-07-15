class RenameltEvidenceColumns < ActiveRecord::Migration
  def up
    rename_column :elt_case_evidences, :file_name, :elt_evidence_file_name
    rename_column :elt_case_evidences, :content_type, :elt_evidence_content_type
    rename_column :elt_case_evidences, :file_size, :elt_evidence_file_size
  end

  def down
    rename_column :elt_case_evidences, :elt_evidence_file_name, :file_name
    rename_column :elt_case_evidences, :elt_evidence_content_type, :content_type
    rename_column :elt_case_evidences, :elt_evidence_file_size, :file_size
  end
end
