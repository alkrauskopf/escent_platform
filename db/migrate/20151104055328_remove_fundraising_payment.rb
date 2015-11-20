class RemoveFundraisingPayment < ActiveRecord::Migration
  def self.up
    remove_column :payments, :fundraising_campaign_id
  end

  def self.down
    add_column :payments, :fundraising_campaign_id, :integer
  end
end
