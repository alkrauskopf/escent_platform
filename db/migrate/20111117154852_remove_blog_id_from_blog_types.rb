class RemoveBlogIdFromBlogTypes < ActiveRecord::Migration
  def self.up

   remove_column :blog_types, :blog_id


  end

  def self.down


   add_column :blog_types, :blog_id, :integer


  end
end
