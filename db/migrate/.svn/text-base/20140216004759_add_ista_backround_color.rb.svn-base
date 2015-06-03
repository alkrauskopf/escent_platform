class AddIstaBackroundColor < ActiveRecord::Migration
  def self.up
    remove_column  :ista_activities, :background
    add_column  :ista_groups, :background_1, :string
    add_column  :ista_groups, :background_2, :string
  end

  def self.down
    remove_column  :ista_groups, :background_1
    remove_column  :ista_groups, :background_2
    add_column  :ista_activities, :background, :string
  end
end
