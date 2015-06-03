class CreateEltIndicatorLookfors < ActiveRecord::Migration
  def self.up
    create_table :elt_indicator_lookfors do |t|
      t.integer :elt_indicator_id
      t.integer :position
      t.string :lookfor

      t.timestamps
    end
    add_index :elt_indicator_lookfors, [:elt_indicator_id], :name => "indicator_id"

  end

  def self.down
    drop_table :elt_indicator_lookfors
  end
end
