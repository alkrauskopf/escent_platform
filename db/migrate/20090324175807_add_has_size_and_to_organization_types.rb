class AddHasSizeAndToOrganizationTypes < ActiveRecord::Migration
  def self.up
    add_column :organization_types, :has_size, :boolean, :default => false
    add_column :organization_types, :has_religious_affiliation, :boolean, :default => false
  end

  def self.down
    remove_column :organization_types, :has_size
    remove_column :organization_types, :has_religious_affiliation
  end
end
