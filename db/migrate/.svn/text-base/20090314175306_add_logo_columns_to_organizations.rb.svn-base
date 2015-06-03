class AddLogoColumnsToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :logo_file_name, :string # Original filename
    add_column :organizations, :logo_content_type, :string # Mime type
    add_column :organizations, :logo_file_size, :integer # File size in bytes
  end

  def self.down
    remove_column :organizations, :logo_file_name
    remove_column :organizations, :logo_content_type
    remove_column :organizations, :logo_file_size
  end
end
