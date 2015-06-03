class AddShouldInformToPrayerPledges < ActiveRecord::Migration
  def self.up
    add_column :prayer_pledges, :should_inform, :boolean, :default => true
  end

  def self.down
    remove_column :prayer_pledges, :should_inform
  end
end
