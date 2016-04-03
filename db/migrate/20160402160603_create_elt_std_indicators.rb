class CreateEltStdIndicators < ActiveRecord::Migration
  def self.up
    create_table :elt_std_indicators do |t|
      t.integer :elt_element_id
      t.integer :position, default: 1
      t.text :description
      t.boolean :is_active, default: false

      t.timestamps
    end
    add_index :elt_std_indicators, [:elt_element_id]
  end

  def self.down
    drop_table :elt_std_indicators
  end
end
