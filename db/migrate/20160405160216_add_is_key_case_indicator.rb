class AddIsKeyCaseIndicator < ActiveRecord::Migration
  def self.up
    add_column :elt_case_indicators, :is_key, :boolean, :default => false
  end

  def self.down
    remove_column :elt_case_indicators, :is_key
  end
end
