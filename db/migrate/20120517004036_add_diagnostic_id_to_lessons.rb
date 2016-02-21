class AddDiagnosticIdToLessons < ActiveRecord::Migration
  def self.up

   add_column :tlt_diagnostic_lessons, :tlt_diagnostic_id, :integer

    add_index :tlt_diagnostic_lessons, :tlt_diagnostic_id, :name => 'diagnostic'
    add_index :tlt_diagnostic_lessons, :tlt_activity_type_id, :name => 'activity_type'

  end

  def self.down

   remove_column :tlt_diagnostic_lessons, :tlt_diagnostic_id
  end
end
