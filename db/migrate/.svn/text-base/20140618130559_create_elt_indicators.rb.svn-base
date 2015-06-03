class CreateEltIndicators < ActiveRecord::Migration
  def self.up
    create_table :elt_indicators do |t|
      t.integer :elt_element_id
      t.integer :position
      t.integer :weight
      t.text :indicator, :limit => 512
      t.boolean :is_active, :default => true

      t.timestamps
    end
    add_column :elt_indicators, :form_background, :string, :limit => 7
    add_index :elt_indicators, [:elt_element_id]
  end

  def self.down
    drop_table :elt_indicators
  end
end
