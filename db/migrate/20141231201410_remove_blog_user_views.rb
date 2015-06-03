class RemoveBlogUserViews < ActiveRecord::Migration
  def self.up
   remove_column  :blogs, :user_views
  end

  def self.down
   add_column  :blogs, :user_views, :integer, :default=> 0
  end
end
