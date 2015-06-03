class RenameCoSubjectsGlInCoGles < ActiveRecord::Migration
  def self.up

    rename_column :co_gles, :co_subjects_gl_id, :co_grade_level_id  
  
  end

  def self.down
  end
end
