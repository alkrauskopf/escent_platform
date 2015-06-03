class RemoveLevelsFromCoGle < ActiveRecord::Migration
  def self.up
 
    add_column :co_gles, :co_subjects_gl_id, :integer
    remove_column :co_gles, :low_grade
    remove_column :co_gles, :high_grade
    remove_column :co_gles, :grade_label
  
  end

  def self.down

    remove_column :co_gles, :co_subjects_gl_id  
    add_column :co_gles, :low_grade, :integer
    add_column :co_gles, :high_grade, :integer
    add_column :co_gles, :grade_label, :string
    
  end
end
