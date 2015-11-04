class DropMiscContentTables < ActiveRecord::Migration
  def self.up
    drop_table :content_details
    drop_table :content_log
    drop_table :content_ratings
    drop_table :content_rating_options
    drop_table :content_rating_types
    drop_table :content_source_types
    drop_table :content_sources
    drop_table :content_tags
    drop_table :tags
    drop_table :content_tracking_types
    drop_table :content_trackings

  end

  def self.down
  end
end
