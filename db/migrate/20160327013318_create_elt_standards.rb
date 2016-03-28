class CreateEltStandards < ActiveRecord::Migration
  def self.up
    create_table :elt_standards do |t|
      t.integer :organization_id
      t.text :abbrev, limit: 8
      t.text :name,   limit: 120
      t.boolean :is_active, default: false
      t.boolean :is_public, default: true

      t.timestamps
    end
    add_index :elt_standards, [:organization_id]
  end

  def self.down
    drop_table :elt_standards
  end
end
