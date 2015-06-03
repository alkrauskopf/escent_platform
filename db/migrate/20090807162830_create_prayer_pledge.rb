class CreatePrayerPledge < ActiveRecord::Migration
  def self.up
    create_table :prayer_pledges do |t|
      t.string :first_name, :limit => 50
      t.string :last_name,  :limit => 50
      t.string :email_address,  :limit => 512      
      t.string :state_province,  :limit => 50
      t.string :country, :city
      t.string :phone_number, :phone_provider
      t.boolean :send_reminder_day_before, :send_interest_of_interest
      t.integer :organization_id
      t.timestamps
    end
    add_column :users, :city, :string
  end

  def self.down
    remove_column :users, :city
    drop_table :prayer_pledges
  end
end
