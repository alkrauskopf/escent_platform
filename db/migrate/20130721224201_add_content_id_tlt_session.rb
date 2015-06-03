class AddContentIdTltSession < ActiveRecord::Migration
  def self.up
     add_column  :tlt_sessions, :content_id, :integer
     add_index  :tlt_sessions, :content_id
  end

  def self.down
     remove_column  :tlt_sessions, :content_id
  end
end
