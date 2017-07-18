class EmptyGarbageContentColumns < ActiveRecord::Migration
  def up
    remove_column :contents, :child_content_id
    remove_column :contents, :related_content_type_id
    remove_column :contents, :mature_content
    remove_column :contents, :user_rating_enabled
    remove_column :contents, :file_name
    remove_column :contents, :package_id
    remove_column :contents, :source_url_protocol
    remove_column :contents, :duration
    remove_column :contents, :creator_name
    remove_column :contents, :star_performer
    remove_column :contents, :series
    remove_column :contents, :pending
    remove_column :contents, :content_upload_source_id
    remove_column :contents, :subject_area_old
    remove_column :contents, :resource_type
  end

  def down
    add_column :contents, :child_content_id, :integer
    add_column :contents, :related_content_type_id, :integer
    add_column :contents, :mature_content, :integer
    add_column :contents, :user_rating_enabled, :integer
    add_column :contents, :file_name, :string
    add_column :contents, :package_id, :integer
    add_column :contents, :source_url_protocol, :string
    add_column :contents, :duration, :integer
    add_column :contents, :creator_name, :string
    add_column :contents, :star_performer, :string
    add_column :contents, :series, :string
    add_column :contents, :pending, :integer
    add_column :contents, :content_upload_source_id, :integer
    add_column :contents, :subject_area_old, :string
    add_column :contents, :resource_type, :string
  end
end
