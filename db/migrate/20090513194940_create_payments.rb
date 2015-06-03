class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :merchant_account_id
      t.integer :transaction_status_id
      t.integer :fundraising_objective_id
      t.integer :user_id
      t.decimal :amount, :precision => 9, :scale => 2, :default => 0.0
      t.string :memo
      t.string :authorization_code
      t.string :response_message
      t.string :card_number, :limit =>32
      t.integer :organization_id
      t.string :card_holder_name
      t.string :billing_address
      t.string :billing_city
      t.string :billing_state_province
      t.string :billing_postal_code
      t.string :billing_country
      t.string :billing_phone, :limit => 20
      t.string :card_type, :limit => 32
      

      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
