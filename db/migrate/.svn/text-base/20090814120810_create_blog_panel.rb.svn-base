class CreateBlogPanel < ActiveRecord::Migration
  def self.up
    create_table :blog_panels, :force => true do |t|
      t.integer :user_id
      t.timestamps
    end
    add_column :blogs, :blog_panel_id, :integer
  end

  def self.down
    remove_column :blogs, :blog_panel_id
    drop_table :blog_panels
  end
end
