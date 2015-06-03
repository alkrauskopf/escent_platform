class AddUserIdToPrayerPledge < ActiveRecord::Migration
  def self.up
    add_column :prayer_pledges, :user_id, :integer
  end

  def self.down
    remove_column :prayer_pledges, :user_id
  end
end
