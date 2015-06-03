class AddBlogFields < ActiveRecord::Migration
  def self.up

   add_column :blogs, :position, :integer
   add_column :blogs, :blog_type_id, :integer   
   add_column :blogs, :is_commentable, :boolean

   add_column :blog_posts, :position, :integer
   add_column :blog_posts, :is_active, :boolean
   add_column :blog_posts, :is_featured, :boolean
         
   execute "UPDATE blogs SET is_commentable = 1"
   execute "UPDATE blogs SET blog_type_id = 1"
   execute "UPDATE blog_posts SET is_active = 1"
        
  end

  def self.down

    remove_column :blogs, :position
    remove_column :blogs, :blog_type_id   
    remove_column :blogs, :is_commentable

    remove_column :blog_posts, :position
    remove_column :blog_posts, :is_active   
    remove_column :blog_posts, :is_featured

  end
end
