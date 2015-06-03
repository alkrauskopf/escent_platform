class CreateTltSessionVideos < ActiveRecord::Migration
  def self.up
    create_table :tlt_session_videos do |t|
      t.integer :tlt_session_id
      t.binary :embed_code

      t.timestamps
    end
  add_index :tlt_session_videos, :tlt_session_id

  end

  def self.down
    drop_table :tlt_session_videos
  end
end
