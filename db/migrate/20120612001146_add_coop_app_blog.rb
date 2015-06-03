class AddCoopAppBlog < ActiveRecord::Migration
  def self.up
     add_column  :blogs, :coop_app_id, :integer
     add_index  :blogs, :coop_app_id
  end

  def self.down
     remove_column  :blogs, :coop_app_id
  end
end
