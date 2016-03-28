class AddIsPublicToEltFrameworks < ActiveRecord::Migration
  def self.up
    add_column :elt_frameworks, :is_public, :boolean, default: true
    add_column :elt_frameworks, :is_active, :boolean, default: true
  end

  def self.down
    remove_column :elt_frameworks, :is_active
    remove_column :elt_frameworks, :is_public
  end
end
