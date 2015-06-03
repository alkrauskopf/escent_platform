class RenameCommentsBlogId < ActiveRecord::Migration
  def self.up
    rename_column :comments , :blog_id , :blog_post_id 
  end

  def self.down
    rename_column :comments , :blog_post_id , :blog_id
  end
end
