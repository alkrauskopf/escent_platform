class DenominationTableRename < ActiveRecord::Migration
  def self.up
    rename_table :denominations, :religious_affiliations
    rename_column :organizations, :denomination_id, :religious_affiliation_id
    rename_column :users, :denomination_id, :religious_affiliation_id
  end

  def self.down
    rename_table :religious_affiliations, :denominations
    rename_column :organizations, :religious_affiliation_id, :denomination_id
    rename_column :users, :religious_affiliation_id, :denomination_id
  end
end
