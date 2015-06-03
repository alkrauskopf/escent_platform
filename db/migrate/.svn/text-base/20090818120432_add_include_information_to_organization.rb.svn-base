class AddIncludeInformationToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations , :include_information , :boolean , :default => true
  end

  def self.down
    remove_column :organizations , :include_information
  end
end
