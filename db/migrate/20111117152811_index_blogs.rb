class IndexBlogs < ActiveRecord::Migration
  def self.up

    add_index :blogs, :organization_id
    add_index :blogs, :active
    add_index :blogs, :blog_type_id

    add_index :blog_users, :blog_id
    add_index :blog_users, :user_id   

    add_index :blog_posts, :blog_id
    add_index :blog_posts, :user_id
    add_index :blog_posts, :is_active

  end

  def self.down

    remove_index :blogs, :organization_id
    remove_index :blogs, :active
    remove_index :blogs, :blog_type_id

    remove_index :blog_users, :blog_id
    remove_index :blog_users, :user_id   

    remove_index :blog_posts, :blog_id
    remove_index :blog_posts, :user_id
    remove_index :blog_posts, :is_active

  end
end
