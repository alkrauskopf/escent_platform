class CreateEltCaseIndicators < ActiveRecord::Migration
  def self.up
    create_table :elt_case_indicators do |t|
      t.integer :elt_case_id
      t.integer :elt_indicator_id
      t.integer :rating
      t.text :evidence, :limit => 250

      t.timestamps
    end

    add_index :elt_case_indicators, [:elt_case_id]
    add_index :elt_case_indicators, [:elt_indicator_id]

  end

  def self.down
    drop_table :elt_case_indicators
  end
end
