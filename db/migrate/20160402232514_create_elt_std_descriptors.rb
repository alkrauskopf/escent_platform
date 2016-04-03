class CreateEltStdDescriptors < ActiveRecord::Migration
  def self.up
    create_table :elt_std_descriptors do |t|
      t.integer :elt_std_indicator_id
      t.integer :position, :default => 1
      t.text :description

      t.timestamps
    end
    add_index :elt_std_descriptors, [:elt_std_indicator_id]
  end

  def self.down
    drop_table :elt_std_descriptors
  end
end
