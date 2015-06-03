class CreateEltRelatedIndicators < ActiveRecord::Migration
  def self.up
    create_table :elt_related_indicators do |t|
      t.integer :elt_indicator_id
      t.integer :related_indicator_id

      t.timestamps
    end
    add_index :elt_related_indicators, [:elt_indicator_id, :related_indicator_id], :name => "index_indicator_id", :unique => true
    add_index :elt_related_indicators, [:related_indicator_id, :elt_indicator_id], :name => "index_related_id", :unique => true
  end

  def self.down
    drop_table :elt_related_indicators
  end
end
