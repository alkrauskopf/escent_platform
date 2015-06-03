class AddDescriptionToActStandards < ActiveRecord::Migration
  def self.up
    add_column :act_standards, :description, :text
  end

  def self.down
    remove_column :act_standards, :description
  end
end
