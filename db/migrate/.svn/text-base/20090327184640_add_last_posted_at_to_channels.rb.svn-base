class AddLastPostedAtToChannels < ActiveRecord::Migration
  def self.up
    add_column :channels, :last_posted_at, :datetime
  end

  def self.down
    remove_column :channels, :last_posted_at
  end
end
