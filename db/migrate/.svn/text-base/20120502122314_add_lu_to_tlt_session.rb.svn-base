class AddLuToTltSession < ActiveRecord::Migration
  def self.up

   add_column :tlt_sessions, :topic_id, :integer
   add_index  :tlt_sessions, :topic_id

  end

  def self.down

   remove_column :tlt_sessions, :topic_id

  end
end
