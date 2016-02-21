class AddSubjDiagnostic < ActiveRecord::Migration
  def self.up

   add_column :tlt_diagnostics, :subject_area_id, :integer
   add_column :tlt_diagnostics, :organization_id, :integer
 
   add_index :tlt_diagnostics, :subject_area_id, :name => 'subject'
   add_index :tlt_diagnostics, :organization_id, :name => 'organization'

  end

  def self.down

   remove_column :tlt_diagnostics, :subject_area_id
   remove_column :tlt_diagnostics, :organization_id

  end
end
