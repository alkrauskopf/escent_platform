class AddDiagnosticIdToLessons < ActiveRecord::Migration
  def self.up

   add_column :tlt_diagnostic_lessons, :tlt_diagnostic_id, :integer

    add_index :tlt_diagnostic_lessons, :tlt_diagnostic_id
    add_index :tlt_diagnostic_lessons, :tlt_activity_type_id

  end

  def self.down

   remove_column :tlt_diagnostic_lessons, :tlt_diagnostic_id
  end
end
