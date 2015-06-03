class CreateItlTemplates < ActiveRecord::Migration
  def self.up
    create_table :itl_templates do |t|
      t.integer :organization_id
      t.string :name, :limit=>35
      t.text :description
      t.boolean :is_editable, :default=>true
      t.boolean :is_enabled, :default=>false

      t.timestamps
    end
    add_index :itl_templates, :organization_id

  end

  def self.down
    drop_table :itl_templates
  end
end
