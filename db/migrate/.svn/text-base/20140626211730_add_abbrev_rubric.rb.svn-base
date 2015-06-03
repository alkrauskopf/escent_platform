class AddAbbrevRubric < ActiveRecord::Migration
  def self.up
    remove_column  :elt_indicators, :abbrev
    add_column  :elt_rubrics, :abbrev, :string, :limit=>1    
  end

  def self.down
    add_column  :elt_indicators, :abbrev, :string, :limit=>1
    remove_column  :elt_rubrics, :abbrev
  end
end
