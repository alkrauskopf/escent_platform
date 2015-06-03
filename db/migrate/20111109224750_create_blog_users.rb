class CreateBlogUsers < ActiveRecord::Migration
  def self.up
    create_table :blog_users do |t|
      t.integer :blog_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :blog_users
  end
end
