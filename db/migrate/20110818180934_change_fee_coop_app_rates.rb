class ChangeFeeCoopAppRates < ActiveRecord::Migration
  def self.up

  remove_column :coop_app_rates, :fee
  add_column    :coop_app_rates, :pay, :decimal, :precision=>7, :scale=>2  
  
  end

  def self.down

  remove_column :coop_app_rates, :pay
  add_column    :coop_app_rates, :fee, :decimal, :precision=>3, :scale=>2  
  
  end
end
