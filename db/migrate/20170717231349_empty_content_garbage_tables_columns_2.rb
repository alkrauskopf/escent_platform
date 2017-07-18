class EmptyContentGarbageTablesColumns2 < ActiveRecord::Migration
  def up
    drop_table :content_object_type_players
    drop_table :content_uploads
    drop_table :content_upload_sources
  end

  def down
  end
end
