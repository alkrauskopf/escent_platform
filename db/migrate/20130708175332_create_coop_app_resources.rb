class CreateCoopAppResources < ActiveRecord::Migration
  def self.up
    create_table :coop_app_resources do |t|
      t.integer :coop_app_id
      t.integer :organization_id
      t.integer :content_id
      t.boolean :is_featured
      t.integer :position

      t.timestamps
    end
    add_index :coop_app_resources, :coop_app_id
    add_index :coop_app_resources, [:organization_id, :coop_app_id], :name => "org_app"
    add_index :coop_app_resources, :content_id 
  end

  def self.down
    drop_table :coop_app_resources
  end
end
