class CreateIfaOrgOptions < ActiveRecord::Migration
  def self.up
    create_table :ifa_org_options do |t|
      t.integer :organization_id
      t.integer :days_til_repeat
      t.integer :sms_calc_cycle
      t.decimal :sms_h_threshold
      t.integer :pct_correct_red
      t.integer :pct_correct_green
      t.integer :months_for_questions
      t.date :begin_school_year

      t.timestamps
    end
  end

  def self.down
    drop_table :ifa_org_options
  end
end
