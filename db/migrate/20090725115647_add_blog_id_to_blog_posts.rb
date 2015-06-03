class AddBlogIdToBlogPosts < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :blog_id , :integer 
  end

  def self.down
    remove_column :blog_posts , :blog_id
  end
end
