class AddBlogFeatureAndCoverToBlog < ActiveRecord::Migration
  def self.up
    add_column :blogs, :picture_file_name,    :string
    add_column :blogs, :picture_content_type, :string
    add_column :blogs, :picture_file_size,    :integer
    add_column :blogs, :picture_updated_at,   :datetime
    add_column :blogs, :feature, :boolean , :default => false
  end

  def self.down
    remove_column :blogs, :feature
    remove_column :blogs, :picture_updated_at
    remove_column :blogs, :picture_file_size
    remove_column :blogs, :picture_content_type
    remove_column :blogs, :picture_file_name    
  end
end