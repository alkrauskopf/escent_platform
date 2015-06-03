class DeleteAddCoTableInfo < ActiveRecord::Migration
  def self.up
    remove_column :co_standards, :low_grade
    remove_column :co_standards, :high_grade
    rename_column :co_standards, :grade_label, :abbrev 
    add_column :co_gles, :low_grade, :integer
    add_column :co_gles, :high_grade, :integer
    add_column :co_gles, :grade_label, :string  
 
  end

  def self.down
    add_column :co_standards, :low_grade, :integer
    add_column :co_standards, :high_grade, :integer
    rename_column :co_standards, :abbrev, :grade_label
    remove_column :co_gles, :low_grade
    remove_column :co_gles, :high_grade
    remove_column :co_gles, :grade_label
 
  end
end
