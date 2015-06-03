class CreateBlogPostRelatedPosts < ActiveRecord::Migration
  def self.up
    create_table :blog_post_related_posts do |t|
      t.integer :blog_post_id
      t.integer :related_post_id

      t.timestamps
    end
    add_index :blog_post_related_posts, :blog_post_id
    add_index :blog_post_related_posts, :related_post_id    
  end

  def self.down
    drop_table :blog_post_related_posts
  end
end
