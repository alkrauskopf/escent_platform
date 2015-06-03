class AddBlogViews < ActiveRecord::Migration
  def self.up

   add_column  :blogs, :views, :integer, :default=> 0
   execute "UPDATE blogs SET views = 0"    
  end

  def self.down

   remove_column  :blogs, :views

  end
end
