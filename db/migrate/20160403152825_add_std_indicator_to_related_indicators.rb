class AddStdIndicatorToRelatedIndicators < ActiveRecord::Migration
  def self.up
    add_column :elt_related_indicators, :elt_std_indicator_id, :integer
    add_index :elt_related_indicators, [:elt_std_indicator_id, :elt_indicator_id], :name=> 'std_to_evidence'
    add_index :elt_related_indicators, [:elt_indicator_id, :elt_std_indicator_id], :name=> 'evidence_to_std'
  end

  def self.down
    remove_column :elt_related_indicators, :elt_std_indicator_id
  end
end
