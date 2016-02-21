class CreateCoopAppContentResourceTypes < ActiveRecord::Migration
  def self.up
    create_table :coop_app_content_resource_types do |t|
      t.integer :coop_app_id
      t.integer :content_resource_type_id

      t.timestamps
    end
    add_index :coop_app_content_resource_types, :coop_app_id
    add_index :coop_app_content_resource_types, :content_resource_type_id, :name => 'resource_type'
  end

  def self.down
    drop_table :coop_app_content_resource_types
  end
end
