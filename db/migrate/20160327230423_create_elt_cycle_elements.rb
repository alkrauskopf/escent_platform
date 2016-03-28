class CreateEltCycleElements < ActiveRecord::Migration
  def self.up
    create_table :elt_cycle_elements do |t|
      t.integer :elt_cycle_id
      t.integer :elt_element_id

      t.timestamps
    end
    add_index :elt_cycle_elements, [:elt_cycle_id, :elt_element_id]
    add_index :elt_cycle_elements, [:elt_element_id, :elt_cycle_id]
  end

  def self.down
    drop_table :elt_cycle_elements
  end
end
