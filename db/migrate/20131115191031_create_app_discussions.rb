class CreateAppDiscussions < ActiveRecord::Migration
  def self.up
    create_table :app_discussions do |t|
      t.integer :coop_app_id
      t.integer :organization_id

      t.timestamps
    end
    add_index :app_discussions, :coop_app_id
    add_index :app_discussions, :organization_id
  end

  def self.down
    drop_table :app_discussions
  end
end
