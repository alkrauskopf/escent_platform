class ChangeContentUploadSourceIdType < ActiveRecord::Migration
  def self.up
    change_column :contents, :content_upload_source_id, :integer, :default => 1
  end

  def self.down
    change_column :contents, :content_upload_source_id, :boolean, :default => 1
  end
end
