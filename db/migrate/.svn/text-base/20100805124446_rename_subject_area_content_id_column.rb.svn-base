class RenameSubjectAreaContentIdColumn < ActiveRecord::Migration
  def self.up
  rename_column :subject_areas , :content_id , :parent_id 
  end

  def self.down
  rename_column :subject_areas , :parent_id , :content_id 
  end
end
