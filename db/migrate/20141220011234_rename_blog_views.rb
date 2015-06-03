class RenameBlogViews < ActiveRecord::Migration
  def self.up

   rename_column  :blogs, :views, :user_views
  end

  def self.down

   rename_column  :blogs, :user_views, :views
  end
end
