class CreateBlogPanelsUsersJoinTable < ActiveRecord::Migration
  def self.up
    create_table :blog_panels_users, :id => false, :force => true do |t|
      t.integer :blog_panel_id, :user_id
    end
  end

  def self.down
    drop_table :blog_panels_users, :id
  end
end
