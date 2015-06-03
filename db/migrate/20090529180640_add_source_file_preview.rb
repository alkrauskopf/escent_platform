class AddSourceFilePreview < ActiveRecord::Migration
  def self.up
    add_column :contents, :source_file_preview_file_name, :string # Original filename
    add_column :contents, :source_file_preview_content_type, :string # Mime type
    add_column :contents, :source_file_preview_file_size, :integer # File size in bytes
    
  end

  def self.down
    remove_column :contents, :source_file_preview_file_name
    remove_column :contents, :source_file_preview_content_type
    remove_column :contents, :source_file_preview_file_size
  end
end