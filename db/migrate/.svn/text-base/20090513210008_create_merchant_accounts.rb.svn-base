class CreateMerchantAccounts < ActiveRecord::Migration
  def self.up
    create_table :merchant_accounts do |t|
      t.integer :organization_id
      t.string :name
      t.string :description
      t.string :gateway_type
      t.string :gateway_partner
      t.string :gateway_login
      t.string :gateway_password
      t.string :gateway_certification_id, :limit => 128
      t.string :vat_registration_number, :limit => 128
      t.boolean :gateway_ignore_avs, :default => true
      t.boolean :gateway_ignore_cvv, :default => true
      t.decimal :payment_transaction_fee, :precision => 9, :scale => 2, :default => 0.0
      t.decimal :payment_transaction_discount_rate, :precision => 9, :scale => 2, :default => 0.0
      t.decimal :refund_transaction_fee, :precision => 9, :scale => 2, :default => 0.0
      t.decimal :chargeback_transaction_fee, :precision => 9, :scale => 2, :default => 0.0
      t.string :card_statement_name, :limit => 128
      t.boolean :visa
      t.boolean :master
      t.boolean :american_express
      t.boolean :discover
      t.boolean :diners_club
      t.boolean :mastro
      t.boolean :jcb
      t.text  :gateway_pem

      t.timestamps
    end
  end

  def self.down
    drop_table :merchant_accounts
  end
end
