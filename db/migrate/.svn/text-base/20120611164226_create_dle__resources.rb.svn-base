class CreateDle_resources < ActiveRecord::Migration
  def self.up
    create_table :dle_resources do |t|
      t.integer :organization_id
      t.integer :content_id
      t.boolean :is_featured
      t.integer :position

      t.timestamps
    end

  add_index :dle_resources, :organization_id
  add_index :dle_resources, :content_id

  end

  def self.down
    drop_table :dle_resources
  end
end
