class AddPovBlogPost < ActiveRecord::Migration
  def self.up
    add_column  :blog_posts, :pov, :string, :limit=>32, :default=>""
  end

  def self.down
    remove_column  :blog_posts, :pov
  end
end
