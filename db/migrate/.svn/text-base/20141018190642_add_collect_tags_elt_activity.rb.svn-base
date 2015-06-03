class AddCollectTagsEltActivity < ActiveRecord::Migration
  def self.up
   add_column  :elt_types, :tag_subject, :boolean, :default=> false
   add_column  :elt_types, :tag_grade, :boolean, :default=> false
   execute "UPDATE elt_types SET tag_subject = 0" 
   execute "UPDATE elt_types SET tag_grade = 0"    
  end

  def self.down
   remove_column  :elt_types, :tag_subject
   remove_column  :elt_types, :tag_grade
  end
end
