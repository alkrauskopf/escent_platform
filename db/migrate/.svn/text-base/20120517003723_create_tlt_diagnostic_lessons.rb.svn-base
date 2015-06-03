class CreateTltDiagnosticLessons < ActiveRecord::Migration
  def self.up
    create_table :tlt_diagnostic_lessons do |t|
      t.integer :tlt_activity_type_id
      t.text :strategies
      t.text :how_effective

      t.timestamps
    end
  end

  def self.down
    drop_table :tlt_diagnostic_lessons
  end
end
