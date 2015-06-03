class CreateContentUploadSources < ActiveRecord::Migration
  def self.up
    create_table :content_upload_sources do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :content_upload_sources
  end
end
