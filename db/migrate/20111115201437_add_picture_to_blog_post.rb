class AddPictureToBlogPost < ActiveRecord::Migration
  def self.up

    add_column :blog_posts, :picture_file_name,    :string
    add_column :blog_posts, :picture_content_type, :string
    add_column :blog_posts, :picture_file_size,    :integer
    add_column :blog_posts, :picture_updated_at,   :datetime
    add_column :blogs, :act_subject_id, :integer

  end

  def self.down
    remove_column :blogs, :act_subject_id
    remove_column :blog_posts, :picture_updated_at
    remove_column :blog_posts, :picture_file_size
    remove_column :blog_posts, :picture_content_type
    remove_column :blog_posts, :picture_file_name 
  end
end
