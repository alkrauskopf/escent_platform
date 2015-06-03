class AddIndicatorNumAbbrev < ActiveRecord::Migration
  def self.up
    add_column  :elt_indicators, :abbrev, :string, :limit=>1
    add_column  :elt_indicators, :ind_num, :integer
  end

  def self.down
    remove_column  :elt_indicators, :abbrev
    remove_column  :elt_indicators, :ind_num
  end
end
