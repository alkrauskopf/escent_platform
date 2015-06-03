class CreateCoopAppRates < ActiveRecord::Migration
  def self.up
    create_table :coop_app_rates do |t|
      t.integer :coop_app_id
      t.string :group_code
      t.decimal :fee, :precision=>3, :scale=>2
      t.string :pay_class
      t.string :pay_period
      t.integer :class_max
      t.integer :class_min

      t.timestamps
    end
  end

  def self.down
    drop_table :coop_app_rates
  end
end
