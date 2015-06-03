class CreateItlOrgOptions < ActiveRecord::Migration
  def self.up
    create_table :itl_org_options do |t|
      t.integer :organization_id
      t.integer :stat_window
      t.boolean :is_concurrent

      t.timestamps
    end

  add_index :itl_org_options, :organization_id

  end

  def self.down
    drop_table :itl_org_options
  end
end
