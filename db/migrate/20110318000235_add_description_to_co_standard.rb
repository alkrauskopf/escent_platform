class AddDescriptionToCoStandard < ActiveRecord::Migration
  def self.up
    add_column :co_standards, :description, :text
  end

  def self.down
    remove_column :co_standards, :description
  end
end
