class RemoveReligiousAffiliationTable < ActiveRecord::Migration
  def self.up
    drop_table :religious_affiliations
  end

  def self.down
  end
end
