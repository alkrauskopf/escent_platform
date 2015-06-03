class RenameIsPostInContents < ActiveRecord::Migration
  def self.up
    rename_column :contents, :is_post, :discussion_content
    rename_column :contents, :is_mature_content, :mature_content
    rename_column :contents, :is_enabled_user_rating, :user_rating_enabled
    
    rename_column :contents, :path_and_file_name, :source_file_file_name
    add_column    :contents, :source_file_content_type, :string, :limit => 128
    add_column    :contents, :source_file_file_size, :integer
    
    add_column    :contents, :content_object_type_id, :integer
#    execute "UPDATE contents,content_object_types SET content_object_type_id=content_object_types.id WHERE contents.content_object_type=content_object_types.content_object_type"
    remove_index :contents, :name => 'index_contents_on_content_object_type'
    remove_column :contents, :content_object_type
  end

  def self.down
    rename_column :contents, :discussion_content, :is_post
    rename_column :contents, :mature_content, :is_mature_content
    rename_column :contents, :user_rating_enabled, :is_enabled_user_rating
    
    rename_column :contents, :source_file_file_name, :path_and_file_name
    remove_column :contents, :source_file_content_type
    remove_column :contents, :source_file_file_size
    
    add_column    :contents, :content_object_type, :string, :limit => 5
    execute "UPDATE contents,content_object_types SET contents.content_object_type=content_object_types.content_object_type WHERE content_object_type_id=content_object_types.id"
    remove_column :contents, :content_object_type_id
  end
end
