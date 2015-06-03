class AddPositionToActStandardContent < ActiveRecord::Migration
  def self.up
    add_column :act_standard_contents, :position,:integer
  end

  def self.down
    remove_column :act_standard_contents, :position
  end
end
