class CreateIfaUserOptions < ActiveRecord::Migration
  def self.up
    create_table :ifa_user_options do |t|
      t.integer :user_id
      t.boolean :is_calibrated
      t.integer :act_master_id
      t.integer :act_rel_reading_id
      t.integer :act_score_range_id
      t.integer :act_standard_id
      t.boolean :is_user_filtered

      t.timestamps
    end
  end

  def self.down
    drop_table :ifa_user_options
  end
end
