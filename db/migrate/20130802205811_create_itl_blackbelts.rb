class CreateItlBlackbelts < ActiveRecord::Migration
  def self.up
    create_table :itl_blackbelts do |t|
      t.integer :content_id
      t.integer :tlt_session_id
      t.integer :observer_id

      t.timestamps
    end
    add_index :itl_blackbelts, [:content_id, :tlt_session_id], :unique => true
    add_index :itl_blackbelts, [:tlt_session_id, :content_id], :unique => true
  end

  def self.down
    drop_table :itl_blackbelts
  end
end
