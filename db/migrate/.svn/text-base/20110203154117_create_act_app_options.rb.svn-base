class CreateActAppOptions < ActiveRecord::Migration
  def self.up
    create_table :act_app_options do |t|
      t.integer :organization_id
      t.integer :days_til_repeat, :default => 0
      t.integer :sms_calc_cycle, :default => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :act_app_options
  end
end
