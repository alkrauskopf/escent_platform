class CreateEltCycles < ActiveRecord::Migration
  def self.up
    create_table :elt_cycles do |t|
      t.integer :organization_id
      t.string :name,   :limit => 64
      t.boolean :is_active, :default => true

      t.timestamps
    end
  add_index :elt_cycles, [:organization_id]
  end

  def self.down
    drop_table :elt_cycles
  end
end
